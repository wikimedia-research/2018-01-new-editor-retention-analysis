select
    rev_user_text as name,
    rev_id, 
    str_to_date(log_timestamp, "%Y%m%d%H%i%S") as reg_dt,
    str_to_date(rev_timestamp, "%Y%m%d%H%i%S") as rev_dt,
    (mob.ct_tag is not null) as mob,
    (ve.ct_tag is not null) as ve
from enwiki.logging
inner join enwiki.revision
on log_user = rev_user
left join enwiki.change_tag mob
on rev_id = mob.ct_rev_id and mob.ct_tag = "mobile edit"
left join enwiki.change_tag ve
on rev_id = ve.ct_rev_id and ve.ct_tag = "visualeditor"
where
    log_type = "newusers" and
    log_action = "create" and
    log_timestamp >= "201612" and
    rev_timestamp >= "201612" and
    -- Remove data for users who haven't yet completed the retention period
    (str_to_date(log_timestamp, "%Y%m%d%H%i%S") + interval 60 day) <= now()