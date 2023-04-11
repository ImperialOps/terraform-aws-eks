# Changelog

All notable changes to this project will be documented in this file.

### [1.7.1](https://github.com/ImperialOps/terraform-aws-eks/compare/v1.7.0...v1.7.1) (2023-04-11)


### Bug Fixes

* **makefile:** remove duplicate infracost installs ([ce630c4](https://github.com/ImperialOps/terraform-aws-eks/commit/ce630c42a960f2d75dd9f60fc02d46cc96b0c240))

## [1.7.0](https://github.com/ImperialOps/terraform-aws-eks/compare/v1.6.1...v1.7.0) (2023-03-31)


### Features

* **crossplane:** add crossplane ([#36](https://github.com/ImperialOps/terraform-aws-eks/issues/36)) ([36db9a8](https://github.com/ImperialOps/terraform-aws-eks/commit/36db9a845bb994b7234e99065b364c61dbc37223))


### Bug Fixes

* **karpenter:** reduce karpenter replica count to 1 ([#37](https://github.com/ImperialOps/terraform-aws-eks/issues/37)) ([34110e3](https://github.com/ImperialOps/terraform-aws-eks/commit/34110e30d212c57e421756fd7370f3a207906765))

### [1.6.1](https://github.com/stuxcd/terraform-aws-eks/compare/v1.6.0...v1.6.1) (2023-03-24)


### Bug Fixes

* **security:** patch go module versions ([#35](https://github.com/stuxcd/terraform-aws-eks/issues/35)) ([50effe5](https://github.com/stuxcd/terraform-aws-eks/commit/50effe501d2988287c1d20a25a92c9f372f94d1a))

## [1.6.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.5.0...v1.6.0) (2023-03-24)


### Features

* **pre-commit:** move terraform docs to run before validate ([#34](https://github.com/stuxcd/terraform-aws-eks/issues/34)) ([cb6b093](https://github.com/stuxcd/terraform-aws-eks/commit/cb6b0938947dc1e92bc144db6482f65a30b84cb3))

## [1.5.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.4.0...v1.5.0) (2023-03-24)


### Features

* **terratest:** add terratest and upgrade eks version ([#33](https://github.com/stuxcd/terraform-aws-eks/issues/33)) ([626c91a](https://github.com/stuxcd/terraform-aws-eks/commit/626c91a43a388b3fe2606f00ca988993dc4e330b))

## [1.4.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.3.2...v1.4.0) (2022-12-06)


### Features

* **karpenter:** upgrade karpenter version ([#24](https://github.com/stuxcd/terraform-aws-eks/issues/24)) ([0c3fe86](https://github.com/stuxcd/terraform-aws-eks/commit/0c3fe8636b0b617cc776d327451631d186e68e41))

### [1.3.2](https://github.com/stuxcd/terraform-aws-eks/compare/v1.3.1...v1.3.2) (2022-12-06)


### Bug Fixes

* **eks-module:** revert eks module to version 0.18 ([5c8e4d9](https://github.com/stuxcd/terraform-aws-eks/commit/5c8e4d98a8f4fe156c56609af63fe560e50a69af))

### [1.3.1](https://github.com/stuxcd/terraform-aws-eks/compare/v1.3.0...v1.3.1) (2022-10-29)


### Bug Fixes

* **karpenter:** upgrade karpenter version ([#19](https://github.com/stuxcd/terraform-aws-eks/issues/19)) ([5fdb4dd](https://github.com/stuxcd/terraform-aws-eks/commit/5fdb4ddd1eac8bb5b21317e94355af353909b309))

## [1.3.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.6...v1.3.0) (2022-10-29)


### Features

* **cluster-version:** add cluster version variable ([#18](https://github.com/stuxcd/terraform-aws-eks/issues/18)) ([592ace7](https://github.com/stuxcd/terraform-aws-eks/commit/592ace7ca1ef33aca465d76fb4fa29ec246ec182))

### [1.2.6](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.5...v1.2.6) (2022-09-09)


### Bug Fixes

* **eks:** reduce ec2 instance size ([#15](https://github.com/stuxcd/terraform-aws-eks/issues/15)) ([4a404af](https://github.com/stuxcd/terraform-aws-eks/commit/4a404af7926fd216013b851253b6f3802297ea99))

### [1.2.5](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.4...v1.2.5) (2022-09-09)


### Bug Fixes

* **test:** increase ec2 size ([#14](https://github.com/stuxcd/terraform-aws-eks/issues/14)) ([2941926](https://github.com/stuxcd/terraform-aws-eks/commit/2941926669827349a14e12b4df3929546c555330))

### [1.2.4](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.3...v1.2.4) (2022-09-09)


### Bug Fixes

* **pr-title:** add pr title check for standardized commits ([b3b331a](https://github.com/stuxcd/terraform-aws-eks/commit/b3b331a56308c5d69f571f0a3eaf7c456e5ffcb3))

### [1.2.3](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.2...v1.2.3) (2022-08-26)


### Bug Fixes

* **infracost:** infracost notification always ([b953751](https://github.com/stuxcd/terraform-aws-eks/commit/b953751984fae6b1f35be8cfb46d22cff059e6a0))

### [1.2.2](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.1...v1.2.2) (2022-08-26)


### Bug Fixes

* **docs:** testing semantic releaser and slack ([4a65ecf](https://github.com/stuxcd/terraform-aws-eks/commit/4a65ecf75b992cbed9f15ebd749519c444b04087))
* **pre-commit:** update infracost path ([dd305ac](https://github.com/stuxcd/terraform-aws-eks/commit/dd305ac7872b5d84e0a23e14fd9426a9da862eb3))

### [1.2.1](https://github.com/stuxcd/terraform-aws-eks/compare/v1.2.0...v1.2.1) (2022-08-26)


### Bug Fixes

* **docs:** this is a test ([c55ae1e](https://github.com/stuxcd/terraform-aws-eks/commit/c55ae1ebccdeb3e1109db258323538ff8e7b8caa))

## [1.2.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.1.1...v1.2.0) (2022-08-26)


### Features

* **infracost:** introduce infracost and update pre-commit ([21477c1](https://github.com/stuxcd/terraform-aws-eks/commit/21477c103888f395fad3c8b0780ff6d64a0fc5b3))

### [1.1.1](https://github.com/stuxcd/terraform-aws-eks/compare/v1.1.0...v1.1.1) (2022-08-26)


### Bug Fixes

* **versions.tf:** Update terraform required version ([df07bdc](https://github.com/stuxcd/terraform-aws-eks/commit/df07bdc7dc0ade59a1952e0051f8ae539a35874b))

## [1.1.0](https://github.com/stuxcd/terraform-aws-eks/compare/v1.0.0...v1.1.0) (2022-08-24)


### Features

* **all-files:** adds a pre-commit and terraform validation and lint ([d79dc09](https://github.com/stuxcd/terraform-aws-eks/commit/d79dc09f2bafcb22b9a462e5f9284a72eea8f853))
