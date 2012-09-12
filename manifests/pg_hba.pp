define postgres::pg_hba() {
    File <| title == 'pg_hba' |> {
        source => [
            "puppet:///modules/postgres/pg_hba.conf.$title",
        ],
    }
}

# vi:syntax=puppet:filetype=puppet:ts=4:et:
