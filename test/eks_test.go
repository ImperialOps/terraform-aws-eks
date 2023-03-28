package test

import (
	"fmt"
	"os"
	"os/exec"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "github.com/aws/aws-sdk-go/service/iam"
)

func TestTerraformAwsEks(t *testing.T) {
	t.Parallel()

	// The folder where we have our Terraform code
	workingDir := "../examples/main"

	// Create a kubeconfig file that terratest modules can consume
	f, err := os.CreateTemp("", "kubeconfig")
	require.NoErrorf(t, err, "error creating temporary file: %s", err)
	defer os.Remove(f.Name())
	test_structure.SaveString(t, workingDir, "kubeconfig", f.Name())

	// At the end of the test, undeploy using Terraform
	defer test_structure.RunTestStage(t, "teardown", func() {
		undeployUsingTerraform(t, workingDir)
	})

	// Deploy the cluster using Terraform
	test_structure.RunTestStage(t, "deploy_terraform", func() {
		awsRegion := aws.GetRandomStableRegion(t, []string{"eu-west-2", "eu-west-1"}, nil)
		t.Logf("aws region is: %s", awsRegion)
		test_structure.SaveString(t, workingDir, "aws_region", awsRegion)
		deployUsingTerraform(t, awsRegion, workingDir)
	})

	// Validate that the cluster is deployed and is responsive
	test_structure.RunTestStage(t, "validate_cluster", func() {
		awsRegion := test_structure.LoadString(t, workingDir, "aws_region")
		validateClusterRunning(t, awsRegion, workingDir)
	})

	// Validate cluster can scale up
	test_structure.RunTestStage(t, "scale_nodes_up", func() {
		validateNodeScaleUp(t, workingDir)
	})

	// Validate cluster can scale down
	test_structure.RunTestStage(t, "scale_nodes_down", func() {
		validateNodeScaleDown(t, workingDir)
	})

	// Validate storage class creates volumes
	test_structure.RunTestStage(t, "storage_class", func() {
		validateStorageClass(t, workingDir)
	})

	// Validate crossplane creates resouse
	test_structure.RunTestStage(t, "crossplane", func() {
		awsRegion := test_structure.LoadString(t, workingDir, "aws_region")
		validateCrossplane(t, awsRegion, workingDir)
	})
}

// Deploy the terraform-packer-example using Terraform
func deployUsingTerraform(t *testing.T, awsRegion string, workingDir string) {
	// a unique cluster ID so we won't clash with anything already in the AWS account
	clusterName := fmt.Sprintf("terratest-%s", random.UniqueId())
	t.Logf("cluster name is: %s", clusterName)
	test_structure.SaveString(t, workingDir, "cluster_name", clusterName)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"aws_region":   awsRegion,
			"cluster_name": clusterName,
		},

		NoColor: true,
	})

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Undeploy the terraform-aws-eks deployment using Terraform
func undeployUsingTerraform(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

// Validate the cluster is running
func validateClusterRunning(t *testing.T, awsRegion string, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	expectedClusterName := test_structure.LoadString(t, workingDir, "cluster_name")
	kubeconfig := test_structure.LoadString(t, workingDir, "kubeconfig")

	// Run `terraform output` to get the value of an output variable
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	assert.Equal(t, clusterName, expectedClusterName)

	cmd := exec.Command("aws", "eks", "update-kubeconfig", "--name", clusterName, "--region", awsRegion, "--kubeconfig", kubeconfig)
	err := cmd.Run()
	require.NoErrorf(t, err, "error running aws command", cmd.Args)
}

// Validate the cluster can scale up
func validateNodeScaleUp(t *testing.T, workingDir string) {
	kubeconfig := test_structure.LoadString(t, workingDir, "kubeconfig")
	kubeResourcePath := "../examples/main/manifests/node_scaling_test.yaml"
	options := k8s.NewKubectlOptions("", kubeconfig, "default")
	filter := v1.ListOptions{
		LabelSelector: "app=node-scaling-test",
	}

	// Get nodes prior to apply
	nodesPre := k8s.GetReadyNodes(t, options)
	test_structure.SaveInt(t, workingDir, "nodes_predeployment", len(nodesPre))

	defer k8s.KubectlDelete(t, options, kubeResourcePath)
	k8s.KubectlApply(t, options, kubeResourcePath)
	k8s.WaitUntilNumPodsCreated(t, options, filter, 4, 6, 5*time.Second)
    time.Sleep(10*time.Second) // wait for node to be created
	k8s.WaitUntilAllNodesReady(t, options, 12, 10*time.Second)

	pods := k8s.ListPods(t, options, filter)
	for _, pod := range pods {
		// allow time for new node to pull image
		k8s.WaitUntilPodAvailable(t, options, pod.GetName(), 12, 5*time.Second)
	}

	// check nodes scaled
	nodesNow := k8s.GetReadyNodes(t, options)
	test_structure.SaveInt(t, workingDir, "nodes_postdeployment", len(nodesNow))
	if len(nodesNow) <= len(nodesPre) {
		t.Errorf("test did not scale up nodes pre: %v post: %v", len(nodesPre), len(nodesNow))
	}
	logger.Logf(t, "scaled up from %v node(s), to %v", len(nodesPre), len(nodesNow))
}

// Validate the cluster can scale down
func validateNodeScaleDown(t *testing.T, workingDir string) {
	kubeconfig := test_structure.LoadString(t, workingDir, "kubeconfig")
	options := k8s.NewKubectlOptions("", kubeconfig, "default")
	nodesPre := test_structure.LoadInt(t, workingDir, "nodes_predeployment")
	nodesPost := test_structure.LoadInt(t, workingDir, "nodes_postdeployment")

	// Sleep to trigger karpenter node consolidation
	logger.Logf(t, "sleeping to permit karpenter to consolidate nodes")
	time.Sleep(180 * time.Second)
	nodesNow := k8s.GetReadyNodes(t, options)

	if nodesPre != len(nodesNow) {
		t.Errorf("expected nodes to scale back down from %v to %v", len(nodesNow), nodesPre)
	}
	logger.Logf(t, "nodes scaled back down from %v nodes, to %v", nodesPost, len(nodesNow))
}

// Validate storage class creates volumes
func validateStorageClass(t *testing.T, workingDir string) {
	kubeconfig := test_structure.LoadString(t, workingDir, "kubeconfig")
	kubeResourcePath := "../examples/main/manifests/storage_class_test.yaml"
	options := k8s.NewKubectlOptions("", kubeconfig, "default")
	filter := v1.ListOptions{
		LabelSelector: "app=storage-class-test",
	}

	// Sleep to trigger karpenter node consolidation
	defer time.Sleep(180 * time.Second)
	defer k8s.KubectlDelete(t, options, kubeResourcePath)
	k8s.KubectlApply(t, options, kubeResourcePath)
	k8s.WaitUntilNumPodsCreated(t, options, filter, 1, 6, 5*time.Second)
    time.Sleep(10*time.Second) // wait for node to be created
	k8s.WaitUntilAllNodesReady(t, options, 12, 10*time.Second)

	pods := k8s.ListPods(t, options, filter)
	for _, pod := range pods {
		k8s.WaitUntilPodAvailable(t, options, pod.GetName(), 12, 5*time.Second)
	}
	logger.Logf(t, "created pod with pvc")
}

// Validate Crossplane create resource
func validateCrossplane(t *testing.T, awsRegion string, workingDir string) {
	kubeconfig := test_structure.LoadString(t, workingDir, "kubeconfig")
	kubeResourcePath := "../examples/main/manifests/crossplane_test.yaml"
	options := k8s.NewKubectlOptions("", kubeconfig, "default")

    sess, err := aws.NewAuthenticatedSession(awsRegion)
    require.NoError(t, err, "expected no error creating aws session") 
    accountId := aws.GetAccountId(t)
    svc := iam.New(sess) 
    policyArn := fmt.Sprintf("arn:aws:iam::%s:policy/crossplane-test", accountId)
    params := &iam.GetPolicyInput{
        PolicyArn: &policyArn,
    }

	// Sleep to allow provider to delete resource
	defer k8s.KubectlDelete(t, options, kubeResourcePath)
	defer time.Sleep(180 * time.Second)
	k8s.KubectlApply(t, options, kubeResourcePath)
    err = svc.WaitUntilPolicyExists(params)
    require.NoError(t, err, "expected no error waiting for policy to be created")

	logger.Logf(t, "created aws iam policy")
}
