targetScope = 'subscription'

// params

@description('The location of the resource group')
param location string

@description('a random key to ensure deployments are unique')
param randomKey string = newGuid()

@description('service principal object id')
param objectId string

@description('tenant id')
param tenantId string

// constants

var suffix = '77697'

// resources

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'my-resource-group-${suffix}'
  location: location
}

// modules

module keyVault './modules/key-vault.bicep' = {
  name: 'key-vault-${randomKey}'
  scope: resourceGroup
  params: {
    name: 'my-key-vault-${suffix}'
    objectId: objectId  
    tenantId: tenantId
  }
}

module staticApp './modules/static-web-app.bicep' = {
   name: 'static-web-app-${randomKey}'
   scope: resourceGroup
   params: {
    name: 'my-static-web-app-${suffix}'
    keyVaultName: keyVault.outputs.name
    randomKey: randomKey
    skuName: 'Free'
    skuTier: 'Free'
   }
   dependsOn: [ keyVault ]
}


module storageAccount './modules/storage-account.bicep' = {
  name: 'storage-account-${randomKey}'
  scope: resourceGroup
  params: {
    name: 'mystorageaccount${suffix}'
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    skuTier:  'Standard'
    keyVaultName: keyVault.outputs.name
    randomKey: randomKey
  }
  dependsOn: [ keyVault ]
}
