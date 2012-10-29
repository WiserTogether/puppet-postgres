class postgres {
    include params

    if !defined (Package[$params::packagename]) {
        package { $params::packagename:
        }
    }

    file { 'pg_hba':
        mode         => 644,
        owner        => 'postgres',
        group        => 'postgres',
        path         => "$params::pgdata/pg_hba.conf",
        notify       => Exec['postgres-reload'],
        require      => [
            Package[$params::packagename],
        ],
    }

    exec { "$params::pgroot/bin/pg_ctl -D $params::pgdata reload":
        alias       => 'postgres-reload',
        user        => 'postgres',
        refreshonly => true,
    }
    file { $params::pgroot:
        ensure => directory,
        mode => 0755,
        owner => 'postgres',
        group => 'postgres'
    }
    file { "$params::pgroot/backupdb.sh":
        ensure => file,
        mode => 0700,
        owner => 'postgres',
        group => 'postgres',
        source => 'puppet:///modules/postgres/backupdb.sh',
    }
    file { "$params::pgroot/copydb.sh":
        ensure => file,
        mode => 0700,
        owner => 'postgres',
        group => 'postgres',
        source => 'puppet:///modules/postgres/copydb.sh',
    }

    file { $params::pgdata:
        ensure => directory,
        mode => 0700,
        owner => 'postgres',
        group => 'postgres',
    }

    exec { "$params::pgroot/bin/initdb":
        unless => "/bin/test -f $params::pgdata/PG_VERSION",
        before => File[$params::pgdata],
        alias  => 'postgres-initdb',
        user => 'postgres',
        require => [
                Package[$params::packagename],
            ]
    }

    service { $params::servicename:
        ensure     => running,
        enable     => true,
        alias      => $servicealias,
        require    => [
            Package[$params::packagename],
            File[$params::pgdata],
        ],
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
