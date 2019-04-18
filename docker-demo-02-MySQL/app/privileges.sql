use mysql;
select host, user from user;
-- 任意地点的root账号可以用一个非常复杂的密码登录（瞎打的），用于禁止无密码登录
GRANT ALL ON *.* to root@'%' identified by 'fwefwefvvdsbwrgbr9jj24intwev0h0nbor32fwfmv1' with grant option;
-- 允许root用户以密码 123456 来登录（仅限本地）
GRANT ALL ON *.* to root@'localhost' identified by '123456' with grant option;
-- 将 docker_test_database 数据库的权限授权给创建的docker用户，密码为 1234567890，但只能本机访问（指容器内）
-- 如果用户docker不存在，则创建用户docker
GRANT ALL ON docker_test_database.* to docker@'localhost' IDENTIFIED by '1234567890';
-- 其他任意地方可以访问，需要使用密码 1654879wddgfg
GRANT ALL ON docker_test_database.* to docker@'%' IDENTIFIED by '1654879wddgfg';
-- mysql新设置用户或权限后需要刷新系统权限否则可能会出现拒绝访问：
FLUSH PRIVILEGES;