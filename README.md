# Azure CDN Front Door Base - Terraform Module
![Testing module](https://github.com/aztfm/terraform-azurerm-key-vault/workflows/Testing%20module/badge.svg?branch=main)
[![TF Registry](https://img.shields.io/badge/terraform-registry-blueviolet.svg)](https://registry.terraform.io/modules/aztfm/key-vault/azurerm/)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/aztfm/terraform-azurerm-key-vault)

## Version compatibility

| Module version | Terraform version | AzureRM version |
| -------------- | ----------------- | --------------- |
| >= 1.x.x       | >= 0.13.x         | >= TBD          |

## Parameters

### Resouce: azurerm_dns_zone

The following parameters are supported:

| Name                              | Description                                                                                                                           |        Type         | Default | Required |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| dns\_zone\_name                   | The name of the DNS Zone. Must be a valid domain name.                                                                                |      `string`       |   n/a   |   yes    |

### Resouce: azurerm_cdn_frontdoor_profile

The following parameters are supported:

| Name                              | Description                                                                                                                           |        Type         | Default | Required |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| profile\_name                     | The name of the CDN Front Door Profile.                                                                                               |      `string`       |   n/a   |   yes    |
| resource\_group\_name             | The name of the resource group in which to create the Application Gateway.                                                            |      `string`       |   n/a   |   yes    |
| response\_timeout\_seconds        | The maximum response timeout in seconds. Possible values are between 16 and 240 seconds.                                              |      `number`       |  `120`  |    no    |
| profile\_tags                     | A mapping of tags to assign to the CDN Front Door Profile resource.                                                                   |    `map(string)`    |  `{}`   |    no    |

### Resouce: azurerm_cdn_frontdoor_origin_group

The following parameters are supported:

| Name                                                               | Description                                                                                          |        Type         | Default | Required |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| origin\_group\_name                                                | The name of the CDN Front Door Origin Group.                                                         |      `string`       |   n/a   |   yes    |
| load\_balancing                                                    | List of objects that represent the configuration of the load balancing.                              | `list(map(string))` |  `[]`   |   yes    |
| health\_probe                                                      | List of objects that represent the configuration of the health probe.                                | `list(map(string))` |  `[]`   |    no    |
| restore\_traffic\_time\_to\_healed\_or\_new\_endpoint\_in\_minutes | The amount of time which should elapse before shifting traffic to another endpoint when a healthy endpoint becomes unhealthy or a new endpoint is added. Possible values are between 0 and 50 minutes. |      `number`       |   `10`  |    no    |

The `health_probe` supports the following:

| Name                              | Description                                                                                                                           |        Type         | Default | Required |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| interval\_in\_seconds             | The number of seconds between health probes. Possible values are between 5 and 31536000 seconds.                                      |      `number`       |   n/a   |   yes    |
| protocol                          | The protocol to use for health probe. Possible values are `Http` and `Https`.                                                         |      `string`       |   n/a   |   yes    |
| path                              | The path relative to the origin that is used to determine the health of the origin.                                                   |      `string`       | `/`     |    no    |
| request\_type                     | The type of health probe request that is made. Possible values are `GET` and `HEAD`.                                                  |      `string`       | `HEAD`  |    no    |


The `load_balancing` supports the following:

| Name                                  | Description                                                                                                                                    |        Type         | Default | Required |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | :-----------------: | :-----: | :------: |
| additional\_latency\_in\_milliseconds | The additional latency in milliseconds for probes to fall into the lowest latency bucket. Possible values are between 0 and 1000 milliseconds. |      `number`       |   `50`  |    no    |
| sample\_size                          | The number of samples to consider for load balancing decisions. Possible values are between 0 and 255.                                         |      `number`       |    `4`  |    no    |
| successful\_samples\_required         | The number of samples within the sample period that must succeed. Possible values are between 0 and 255.                                       |      `number`       |    `3`  |    no    |
