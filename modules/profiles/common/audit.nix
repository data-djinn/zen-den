{
  security = {
    audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
        # increased buffer size
        "-b 8192"
        # audit audit logs
        "-w /var/log/audit -k auditlog"
        # audit audit config
        "-w /etc/audit -p wa -k auditconfig"
        # monitor systemd
        "-w /run/current-system/sw/bin/systemctl -p x -k systemd"
        "-w /etc/systemd/ -p wa -k systemd"
        # monitor apparmor config changes
        "-w /etc/apparmor/ -p wa -k apparmor"
        "-w /etc/apparmor.d/ -p wa -k apparmor"
      ];
    };

    auditd.enable = true;
  };

  environment.etc."audit/auditd.conf".text = ''
    log_file = /var/log/audit/audit.log
    log_format = RAW
    log_group = root
    flush = INCREMENTAL_ASYNC

    # needed for apparmor
    priority_boost = 0


    num_logs = 5
    name_format = NONE
    ##name = mydomain
    max_log_file = 8
    max_log_file_action = ROTATE
    space_left = 75
    space_left_action = SYSLOG
    admin_space_left = 50
    admin_space_left_action = SYSLOG
    disk_full_action = SUSPEND
    disk_error_action = SUSPEND
    use_libwrap = yes
    ##tcp_listen_port = 60
    tcp_listen_queue = 5
    tcp_max_per_addr = 1
    ##tcp_client_ports = 1024-65535
    tcp_client_max_idle = 0
    enable_krb5 = no
    krb5_principal = auditd
    ##krb5_key_file = /etc/audit/audit.key
  '';

  systemd.services.auditd.serviceConfig = {
    # Security enhancements
    CapabilityBoundingSet = "CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE";
    PrivateNetwork = "true";
    PrivateDevices = "yes";
    ProtectControlGroups = "yes";
    ProtectKernelModules = "yes";
    ProtectClock = "true";
    ProtectKernelTunables = "yes";
    RestrictRealtime = "yes";
    SystemCallArchitectures = "native";
  };
}
