Search-AzGraph -Query `
'resourcecontainers
| where type == "microsoft.resources/subscriptions"
| extend inManagementGroup = iif(isnotempty(tags), "True", "False"),
	spendingLimit = properties.subscriptionPolicies.spendingLimit,
	state = properties.state
| project id, name, type, tenantId, inManagementGroup, spendingLimit, state'

Search-AzGraph -Query `
'
Resources
| project tags, subscriptionId
| where tags != "{}"
| where tags != ""
| where tags notcontains "AutomationAccountARMID"
| where tags notcontains "hidden-link"
| where tags notcontains "hidden-title"
| where tags notcontains "Azure Site Recovery Service"
| where tags notcontains "azure-cloud-shell"
| mvexpand tags
'
## Can be further converted with | convertto-{HTML | JSON | XML | CSV}


Search-AzGraph -Query `
'
policyresources
| where type == "microsoft.policyinsights/policystates"
| extend action = tostring(properties.policyDefinitionAction),
	AssignmentName = tostring(properties.policyAssignmentName),
	scope = tostring(properties.policyAssignmentScope),
	compliancestate = tostring(properties.complianceState),
	category = tostring(properties.policySetDefinitionCategory),
	subscription = tostring(properties.subscriptionId),
	groupname = tostring(properties.policyDefinitionGroupNames)
| summarize CompliantCount = countif(compliancestate == "Compliant"), NonCompliantCount = countif(compliancestate == "NonCompliant") by subscription, groupname, AssignmentName, scope
'