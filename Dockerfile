# Dockerfile

# 步骤 1: 基于一个带有具体 Python 版本的官方镜像
FROM jupyter/minimal-notebook:python-3.11

# 步骤 2: 切换到 root 用户，以便安装系统工具和 Python 包
USER root

# 步骤 3: 安装 uv - 一个极速的 Python 包安装器
# 我们使用官方脚本安装，并将其可执行文件移动到系统 PATH 中，以便所有用户都能使用。
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv

# 步骤 4: 复制依赖文件到容器中
COPY requirements.txt /tmp/

# 步骤 5: 使用 uv 安装 requirements.txt 中的 Python 包
# --system 标志告诉 uv 将包安装到当前激活的 Python 环境中（即此镜像的 Conda base 环境），而不是创建新的虚拟环境。
# 这比 mamba/conda 更快。
RUN uv pip install --system -r /tmp/requirements.txt && \
    # 清理 uv 缓存以减小最终镜像的大小
    uv cache clean && \
    # 修复因 root 用户安装导致的文件权限问题，这依然是必需的
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# 步骤 6: 切换回默认的非 root 用户 jovyan
# 此时，jovyan 用户已经可以在终端里直接使用 uv 命令了。
USER ${NB_UID}
