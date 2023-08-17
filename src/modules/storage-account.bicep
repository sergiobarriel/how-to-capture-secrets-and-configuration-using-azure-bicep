// params

@minLength(3)
@maxLength(24)
@description('storage account name')
param name string

@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', 'Premium_LRS'])
param skuName string = 'Standard_LRS'

@allowed(['Standard', 'Premium'])
param skuTier string = 'Standard'

@allowed(['Storage', 'StorageV2', 'BlobStorage', 'FileStorage', 'BlockBlobStorage'])
param kind string = 'StorageV2'

@description('key vault name')
param keyVaultName string

@description('deployment random key')
param randomKey string

// resource

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: kind
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// outputs

var storageAccountKeys = storageAccount.listKeys()

// outputs to key vault

module secret1 './key-vault-secret.bicep' = {
  name: 'stg-account-${name}-pri-${randomKey}'
  params: {
    name: keyVaultName
    secretName: 'STORAGE-ACCOUNT-${toUpper(name)}-PRIMARY-CONNECTION-STRING'
    secretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKeys.keys[0].value};EndpointSuffix=core.windows.net'    
  }
}

module secret2 './key-vault-secret.bicep' = {
  name: 'stg-account-${name}-sec-${randomKey}'
  params: {
    name: keyVaultName
    secretName: 'STORAGE-ACCOUNT-${toUpper(name)}-SECONDARY-CONNECTION-STRING'
    secretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccountKeys.keys[1].value};EndpointSuffix=core.windows.net'    
  }
}
