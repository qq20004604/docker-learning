use mysql;
select host, user from user;
-- 允许root用户以密码 123456 来登录
grant all on *.* to root@'localhost' identified by '123456' with grant option;

-- 将 docker_test_database 数据库的权限授权给创建的docker用户，密码为 1234567890，但只能本机访问（指容器内）
-- 如果用户docker不存在，则创建用户docker
grant all on docker_test_database.* to docker@'localhost' identified by '1234567890' with grant option;
-- 其他任意地方可以访问，需要使用密码 1654879wddgfg
grant all on docker_test_database.* to docker@'%' identified by '1654879wddgfg' with grant option;
-- mysql新设置用户或权限后需要刷新系统权限否则可能会出现拒绝访问：
flush privileges;