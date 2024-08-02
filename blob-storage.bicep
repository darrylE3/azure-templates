var name = toLower(replace(resourceGroup().name, '-', ''))
var location = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      changeFeed: {enabled: false}
      restorePolicy: {enabled: false}
      cors:{corsRules: []}
      containerDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: true
        days: 7
      }
      isVersioningEnabled: false
    }
  }

  resource fileServices 'fileServices' = {
    name: 'default'
    properties: {
      protocolSettings: {smb: {}}
      cors: {corsRules: []}
      shareDeleteRetentionPolicy: {
        enabled: true
        days: 7
      }
    }
  }

  resource queueServices 'queueServices' = {
    name: 'default'
    properties: {
      cors: {corsRules: []}
    }
  }

  resource tableServices 'tableServices' = {
    name: 'default'
    properties: {
      cors: {corsRules: []}
    }
  }
}

output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output storageAccountName string = storageAccount.name
