# == Class: zabbix::agent::config
#
class zabbix::agent::config {

  include ::zabbix::agent

  File {
    owner => 'zabbix',
    group => 'zabbix',
  }

  file { '/var/lib/zabbix':
    ensure  => 'directory',
    path    => $::zabbix::agent::user_home_dir,
    mode    => '0750',
  }

  file { '/var/log/zabbix':
    ensure  => 'directory',
    path    => $::zabbix::agent::log_dir,
    owner   => 'root',
    mode    => '0775',
  }

  file { '/var/run/zabbix':
    ensure  => 'directory',
    path    => $::zabbix::agent::pid_dir,
    owner   => 'root',
    mode    => '0775',
  }

  file { '/etc/zabbix_agentd.conf':
    ensure  => 'file',
    path    => $::zabbix::agent::config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('zabbix/agent/zabbix_agentd.conf.erb'),
  }

  file { '/etc/zabbix_agentd.conf.d':
    ensure  => 'directory',
    path    => $::zabbix::agent::config_d_dir,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
  }

  if $::zabbix::agent::manage_logrotate {
    # Make using logrotate::rule optional
    # because the version that supports 'su' is
    # not yet in the Forge.
    if $::zabbix::agent::use_logrotate_rule {
      logrotate::rule { 'zabbix-agent':
        path          => $::zabbix::agent::log_file,
        missingok     => true,
        rotate_every  => $::zabbix::agent::logrotate_every,
        ifempty       => false,
        compress      => true,
        create        => true,
        create_mode   => '0664',
        create_owner  => 'zabbix',
        create_group  => 'zabbix',
        su            => true,
        su_owner      => 'zabbix',
        su_group      => 'zabbix',
      }
    } else {
      file { '/etc/logrotate.d/zabbix-agent':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('zabbix/agent/logrotate/zabbix-agent.erb'),
      }
    }
  }

}
