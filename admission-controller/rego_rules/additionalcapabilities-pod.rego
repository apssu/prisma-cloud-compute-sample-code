# PolicyName:  PSS - Baseline - Pod with containers that run unauthorized additional capabilities
# Description: This policy identifies Pods with containers that run unauthorized additional capabilities



authorizedcapabilities = {"AUDIT_WRITE", "CHOWN", "DAC_OVERRIDE", "FOWNER", "FSETID", "KILL", "MKNOD","NET_BIND_SERVICE", "SETFCAP", "SETGID", "SETPCAP","SETUID", "SYS_CHROOT"}

match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "Pod"
    container := input.request.object.spec.containers[_].securityContext
    addedcap := {cap | cap := container.capabilities.add[_]}
    unauthcapabilities := addedcap - authorizedcapabilities
    count(unauthcapabilities) != 0
    name := input.request.object.metadata.name
    msg := sprintf("Pod with containers using unauthorized capabilities identified in %v", [name])
}

