# Dockerfile

# 步骤 1: 基于一个带有具体 Python 版本的官方镜像
FROM jupyter/minimal-notebook:python-3.11

# 步骤 2: 切换到 root 用户进行系统级安装
USER root

# 步骤 3: 安装 uv 所需的系统依赖并清理
RUN apt-get update && apt-get install -y unzip && \
    rm -rf /var/lib/apt/lists/*

# 步骤 4: 切换回 jovyan 用户来安装 uv
# 因为安装脚本默认会装到当前用户的家目录，所以我们直接切换到 jovyan 用户来执行
# 这样 uv 会被自然地安装到 /home/jovyan/.local/bin，且文件所有权也是正确的
USER ${NB_USER}
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 步骤 5: 复制依赖文件
# 注意：COPY 指令会继承上一条 USER 指令的用户，所以这里复制的文件所有者是 jovyan，这很好！
COPY --chown=${NB_USER}:${NB_GID} requirements.txt /tmp/

# 步骤 6: 使用 uv 安装 Python 包
# 因为 uv 已经在 PATH 中，所以可以直接调用
# --system 会安装到 Conda base 环境
RUN uv pip install --system -r /tmp/requirements.txt && \
    uv cache clean && \
    uv --version && uvx --version

# 步骤 7: 切换回普通用户
USER ${NB_UID}
