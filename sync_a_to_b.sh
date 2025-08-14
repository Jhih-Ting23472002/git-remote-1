#!/bin/bash
# 將 a 專案完整同步到 b，並設定之後自動推送到 a 與 b
# 使用前請修改以下兩個變數

A_REPO="{{a資料庫位置}}"
B_REPO="{{b資料庫位置}}"

set -e

echo "📌 確認目前資料夾是 a 專案..."
if [ ! -d ".git" ]; then
    echo "❌ 當前目錄不是 Git 專案，請先進入 a 專案資料夾"
    exit 1
fi

echo "1️⃣ 抓取 a 遠端所有分支..."
git fetch origin --prune

echo "2️⃣ 建立所有遠端分支的本地追蹤分支..."
for branch in $(git branch -r | grep origin/ | grep -v HEAD); do
    git branch --track "${branch#origin/}" "$branch" 2>/dev/null || true
done

echo "3️⃣ 新增 b 遠端..."
if git remote | grep -q "^mirror$"; then
    echo "⚠️ 已存在 mirror 遠端，略過新增"
else
    git remote add mirror "$B_REPO"
fi

echo "4️⃣ 推送所有分支與 tag 到 b..."
git push mirror --all
git push mirror --tags

echo "5️⃣ 設定 origin 同時推送到 a 與 b..."
git remote set-url --push origin "$A_REPO"
git remote set-url --add --push origin "$B_REPO"

echo "6️⃣ 確認設定結果..."
git remote -v

echo "✅ 完成！以後執行 'git push origin <branch>' 就會同時推到 a 和 b"
