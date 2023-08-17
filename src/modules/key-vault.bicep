// params

@description('key vault name')
param name string

@description('object id of service principal that creates resources on azure')
@minLength(36)
@maxLength(36)
param objectId string

@description('tenant id')
@minLength(36)
@maxLength(36)
param tenantId string

// resource

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    softDeleteRetentionInDays: 7
    enableSoftDelete: true
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        applicationId: ''
        permissions: {
          keys: ['all']
          secrets: ['all']
          certificates: ['all']
          storage: ['all']
        }
      }
    ]
  }
}

// outputs 

output name string = keyVault.name
