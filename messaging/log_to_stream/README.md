# Required IAM Policy for the Service Connector
`allow any-user to use stream-push in compartment id ocid1.compartment.oc1..<ID>> where all {request.principal.type='serviceconnector', target.stream.id='ocid1.stream.oc1.eu-milan-1.<ID>>', request.principal.compartment.id='ocid1.compartment.oc1..<ID>'}`

# Required IAM Policy for the consumer
`Allow group <groupname> to use stream-pull in compartment id ocid1.compartment.oci1..<ID>`