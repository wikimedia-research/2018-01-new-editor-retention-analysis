select 
    mo_1.user as user,
    mo_1.reg_day as reg_day,
    mo_1.revs as mo_1_revs,
    coalesce(mo_2.revs, 0) as mo_2_revs,
    mo_1.reverts as mo_1_reverts,
    coalesce(mo_2.reverts, 0) as mo_2_reverts
from (
    select
        event_user_text as user,
        substr(event_user_creation_timestamp, 0, 10) as reg_day,
        count(*) as revs,
        sum(cast(revision_is_identity_reverted as int)) as reverts
    from wmf.mediawiki_history
    where
        snapshot = "{snapshot}" and
        event_entity = "revision" and
        event_type = "create" and
        wiki_db = "enwiki" and
        event_user_is_created_by_system = 0 and
        event_user_creation_timestamp >= "{start}" and
        event_user_creation_timestamp < "{end}" and
        unix_timestamp(event_timestamp, "yyyy-MM-dd HH:mm:ss.0") <
            (unix_timestamp(event_user_creation_timestamp, "yyyy-MM-dd HH:mm:ss.0") + (30*24*60*60))
    group by event_user_text, event_user_creation_timestamp
    ) mo_1
left join (
    select
        event_user_text as user,
        substr(event_user_creation_timestamp, 0, 10) as reg_day,
        count(*) as revs,
        sum(cast(revision_is_identity_reverted as int)) as reverts
    from wmf.mediawiki_history
    where
        snapshot = "{snapshot}" and
        event_entity = "revision" and
        event_type = "create" and
        wiki_db = "enwiki" and
        event_user_is_created_by_system = 0 and
        event_user_creation_timestamp >= "{start}" and
        event_user_creation_timestamp < "{end}" and
        unix_timestamp(event_timestamp, "yyyy-MM-dd HH:mm:ss.0") >=
            (unix_timestamp(event_user_creation_timestamp, "yyyy-MM-dd HH:mm:ss.0") + (30*24*60*60)) and
        unix_timestamp(event_timestamp, "yyyy-MM-dd HH:mm:ss.0") <
            (unix_timestamp(event_user_creation_timestamp, "yyyy-MM-dd HH:mm:ss.0") + (60*24*60*60))
        group by event_user_text, event_user_creation_timestamp
    ) mo_2
on
    (mo_1.user = mo_2.user and
    mo_1.reg_day = mo_2.reg_day)