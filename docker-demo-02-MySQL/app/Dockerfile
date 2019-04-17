# 指定基础镜像，使用MySQL:5.6版本（因为5.7版本比较复杂）
FROM mysql:5.6
# 环境变量设置，设置mysql登陆时不需密码
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
COPY . /app
# 容器启动命令启动脚本
CMD ["sh", "/app/init.sh",";"]