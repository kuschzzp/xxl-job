-- 创建数据库（注意：PostgreSQL 不支持在 CREATE DATABASE 中指定 charset/collate）
-- CREATE DATABASE xxljob;
-- \c xxljob;

-- 设置字符集（Postgres 默认 UTF8，通常无需手动设置）

-- xxl_job_info
CREATE TABLE xxl_job_info (
                              id SERIAL PRIMARY KEY,
                              job_group INTEGER NOT NULL, -- 执行器主键ID
                              job_desc VARCHAR(255) NOT NULL,
                              add_time TIMESTAMP DEFAULT NULL,
                              update_time TIMESTAMP DEFAULT NULL,
                              author VARCHAR(64) DEFAULT NULL, -- 作者
                              alarm_email VARCHAR(255) DEFAULT NULL, -- 报警邮件
                              schedule_type VARCHAR(50) NOT NULL DEFAULT 'NONE', -- 调度类型
                              schedule_conf VARCHAR(128) DEFAULT NULL, -- 调度配置
                              misfire_strategy VARCHAR(50) NOT NULL DEFAULT 'DO_NOTHING', -- 调度过期策略
                              executor_route_strategy VARCHAR(50) DEFAULT NULL, -- 执行器路由策略
                              executor_handler VARCHAR(255) DEFAULT NULL, -- 执行器任务handler
                              executor_param VARCHAR(512) DEFAULT NULL, -- 执行器任务参数
                              executor_block_strategy VARCHAR(50) DEFAULT NULL, -- 阻塞处理策略
                              executor_timeout INTEGER NOT NULL DEFAULT 0, -- 执行超时时间 秒
                              executor_fail_retry_count INTEGER NOT NULL DEFAULT 0, -- 失败重试次数
                              glue_type VARCHAR(50) NOT NULL, -- GLUE类型
                              glue_source TEXT, -- GLUE源代码
                              glue_remark VARCHAR(128) DEFAULT NULL, -- GLUE备注
                              glue_updatetime TIMESTAMP DEFAULT NULL, -- GLUE更新时间
                              child_jobid VARCHAR(255) DEFAULT NULL, -- 子任务ID
                              trigger_status SMALLINT NOT NULL DEFAULT 0, -- 0-停止 1-运行
                              trigger_last_time BIGINT NOT NULL DEFAULT 0, -- 上次调度时间
                              trigger_next_time BIGINT NOT NULL DEFAULT 0  -- 下次调度时间
);

-- xxl_job_log
CREATE TABLE xxl_job_log (
                             id BIGSERIAL PRIMARY KEY,
                             job_group INTEGER NOT NULL,
                             job_id INTEGER NOT NULL,
                             executor_address VARCHAR(255) DEFAULT NULL,
                             executor_handler VARCHAR(255) DEFAULT NULL,
                             executor_param VARCHAR(512) DEFAULT NULL,
                             executor_sharding_param VARCHAR(20) DEFAULT NULL,
                             executor_fail_retry_count INTEGER NOT NULL DEFAULT 0,
                             trigger_time TIMESTAMP DEFAULT NULL,
                             trigger_code INTEGER NOT NULL,
                             trigger_msg TEXT,
                             handle_time TIMESTAMP DEFAULT NULL,
                             handle_code INTEGER NOT NULL,
                             handle_msg TEXT,
                             alarm_status SMALLINT NOT NULL DEFAULT 0
);

CREATE INDEX idx_trigger_time ON xxl_job_log(trigger_time);
CREATE INDEX idx_handle_code ON xxl_job_log(handle_code);
CREATE INDEX idx_jobid_jobgroup ON xxl_job_log(job_id, job_group);
CREATE INDEX idx_job_id ON xxl_job_log(job_id);

-- xxl_job_log_report
CREATE TABLE xxl_job_log_report (
                                    id SERIAL PRIMARY KEY,
                                    trigger_day TIMESTAMP DEFAULT NULL,
                                    running_count INTEGER NOT NULL DEFAULT 0,
                                    suc_count INTEGER NOT NULL DEFAULT 0,
                                    fail_count INTEGER NOT NULL DEFAULT 0,
                                    update_time TIMESTAMP DEFAULT NULL,
                                    UNIQUE (trigger_day)
);

-- xxl_job_logglue
CREATE TABLE xxl_job_logglue (
                                 id SERIAL PRIMARY KEY,
                                 job_id INTEGER NOT NULL,
                                 glue_type VARCHAR(50) DEFAULT NULL,
                                 glue_source TEXT,
                                 glue_remark VARCHAR(128) NOT NULL,
                                 add_time TIMESTAMP DEFAULT NULL,
                                 update_time TIMESTAMP DEFAULT NULL
);

-- xxl_job_registry
CREATE TABLE xxl_job_registry (
                                  id SERIAL PRIMARY KEY,
                                  registry_group VARCHAR(50) NOT NULL,
                                  registry_key VARCHAR(255) NOT NULL,
                                  registry_value VARCHAR(255) NOT NULL,
                                  update_time TIMESTAMP DEFAULT NULL,
                                  UNIQUE (registry_group, registry_key, registry_value)
);

-- xxl_job_group
CREATE TABLE xxl_job_group (
                               id SERIAL PRIMARY KEY,
                               app_name VARCHAR(64) NOT NULL,
                               title VARCHAR(12) NOT NULL,
                               address_type SMALLINT NOT NULL DEFAULT 0,
                               address_list TEXT,
                               update_time TIMESTAMP DEFAULT NULL
);

-- xxl_job_user
CREATE TABLE xxl_job_user (
                              id SERIAL PRIMARY KEY,
                              username VARCHAR(50) NOT NULL,
                              password VARCHAR(50) NOT NULL,
                              role SMALLINT NOT NULL, -- 0 普通用户 1 管理员
                              permission VARCHAR(255) DEFAULT NULL,
                              UNIQUE (username)
);

-- xxl_job_lock
CREATE TABLE xxl_job_lock (
                              lock_name VARCHAR(50) PRIMARY KEY
);

-- —————————————————————— init data ——————————————————
INSERT INTO xxl_job_group (id, app_name, title, address_type, address_list, update_time)
VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL, '2018-11-03 22:21:31')
ON CONFLICT (id) DO NOTHING;

INSERT INTO xxl_job_info (id, job_group, job_desc, add_time, update_time, author, alarm_email,
                          schedule_type, schedule_conf, misfire_strategy, executor_route_strategy,
                          executor_handler, executor_param, executor_block_strategy, executor_timeout,
                          executor_fail_retry_count, glue_type, glue_source, glue_remark, glue_updatetime,
                          child_jobid)
VALUES (1, 1, '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'CRON', '0 0 0 * * ? *',
        'DO_NOTHING', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化',
        '2018-11-03 22:21:31', '')
ON CONFLICT (id) DO NOTHING;

INSERT INTO xxl_job_user (id, username, password, role, permission)
VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO xxl_job_lock (lock_name)
VALUES ('schedule_lock')
ON CONFLICT (lock_name) DO NOTHING;

SELECT setval(pg_get_serial_sequence('xxl_job_info', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_log', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_log_report', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_logglue', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_registry', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_group', 'id'), 100, false);
SELECT setval(pg_get_serial_sequence('xxl_job_user', 'id'), 100, false);