#!/bin/bash
# ------------------------------------------------------------------
# 配置变量 - 请务必替换为你的实际值
# ------------------------------------------------------------------
PROJECT_ID="your-project-id"
BILLING_ACCOUNT_ID="0X0X0X-0X0X0X-0X0X0X" # 结算账户 ID，格式如 012345-6789AB-CDEF01
PUBSUB_TOPIC="billing-alerts"

echo "正在为项目 $PROJECT_ID 设置 0$ 预算限制..."

# 1. 创建 Pub/Sub 主题
gcloud pubsub topics create $PUBSUB_TOPIC --project=$PROJECT_ID

# 2. 创建预算 (设置 0 美元阈值)
# 注意：该命令可能需要安装 alpha 组件: gcloud components install alpha
gcloud alpha billing budgets create \
  --billing-account=$BILLING_ACCOUNT_ID \
  --display-name="Budget-Limit-0-Dollar" \
  --budget-amount=0.01 \
  --threshold-rule=percent=0.01 \
  --pubsub-topic="projects/$PROJECT_ID/topics/$PUBSUB_TOPIC" \
  --project=$PROJECT_ID

echo "预算已创建，Pub/Sub 主题已连接。"
echo "接下来你需要部署一个 Cloud Function 订阅 $PUBSUB_TOPIC 主题，并在收到消息时执行 'gcloud beta billing projects unlink $PROJECT_ID' 命令。"
echo "请参考文档编写该函数。"
