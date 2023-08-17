@description('static web app name')
param name string

@description('key vault name')
param keyVaultName string

@description('deployment random key')
param randomKey string

@description('static web app tier')
@allowed(['Free', 'Standard'])
param skuTier string = 'Free'

@description('static web app tier')
@allowed(['Free', 'Standard'])
param skuName string = 'Free'

// resource

resource staticWebApp 'Microsoft.Web/staticSites@2021-03-01' = {
  name: name
  location: resourceGroup().location
  sku: {
    name: skuName   
    tier: skuTier
  }
  properties: { }
}

// outputs to key vault 

module secret1 'key-vault-secret.bicep' = {
  name: 'static-app-${name}-deployment-token-${randomKey}'
  params: {
    name: keyVaultName
    secretName: 'DEPLOYMENT-TOKEN-${toUpper(name)}'
    secretValue: staticWebApp.listSecrets().properties.apiKey
  }
}

module secret2 'key-vault-secret.bicep' = {
  name: 'static-app-${name}-hostname-${randomKey}'
  params: {
    name: keyVaultName
    secretName: 'HOSTNAME-${toUpper(name)}'
    secretValue: staticWebApp.properties.defaultHostname
  }
}
