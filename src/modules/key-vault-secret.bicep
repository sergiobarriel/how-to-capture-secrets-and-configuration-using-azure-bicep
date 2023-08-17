@description('key vault name')
param name string

@description('secret name')
param secretName string

@secure()
@description('secret value')
param secretValue string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: name
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: keyVault
  name: toUpper(secretName)
  properties: {
    value: secretValue
    contentType: 'plain/text'
  }
}
