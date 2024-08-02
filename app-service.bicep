param netFrameworkVersion string
param storageAccountName string
@secure()
param sendgridApiKey string
param serverFarmName string
param serverFarmResourceGroupName string
@secure() 
param sqlConnectionString string

var location = resourceGroup().location
var name = resourceGroup().name

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}
var storageAccountKey = storageAccount.listKeys().keys[0].value

resource serverFarm 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: serverFarmName
  scope: resourceGroup(serverFarmResourceGroupName)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: name
  location: location
  kind: 'web'
  properties: { Application_Type: 'web' }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: name
  location: location
  kind: 'app'
  properties: {
    enabled: true
    serverFarmId: serverFarm.id
    siteConfig: {
      netFrameworkVersion: netFrameworkVersion
      appSettings: [
        {
          name: 'ApiUrl'
          value: 'https://${name}.azurewebsites.net/'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'CorsOrigins'
          value: 'https://${name}.azurewebsites.net'
        }
        {
          name: 'FileStorage:AzureAccountKey'
          value: storageAccountKey
        }
        {
          name: 'FileStorage:AzureAccountName'
          value: storageAccountName
        }
        {
          name: 'FileStorage:AzureConnectionString'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccountKey};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'FileStorage:AzurePublicUrl'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FileStorage:Provider'
          value: 'AzureBlob'
        }
        {
          name: 'Identity:Authority'
          value: 'https://${name}.azurewebsites.net/'
        }
        {
          name: 'MSDEPLOY_RENAME_LOCKED_FILES'
          value: '1'
        }
        {
          name: 'SendGrid:ApiKey'
          value: sendgridApiKey
        }
        {
          name: 'WEBSITE_ENABLE_SYNC_UPDATE_SITE'
          value: 'true'
        }
        {
          name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS'
          value: '1'
        }
        {
          name: 'WebSubDirectory'
          value: 'app'
        }
        {
          name: 'WebUrl'
          value: 'https://${name}.azurewebsites.net/app'
        }
        {
          name: 'XDT_MicrosoftApplicationInsights_Mode'
          value: 'Recommended'
        }
      ]
      connectionStrings: [
        {
          connectionString: sqlConnectionString
          name: 'DataContext'
          type: 'SQLAzure'
        }
      ]
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}
