#!/bin/bash

DOCS_ROOT="content/docs"
AUTHOR="LogLee"

# _index.md 생성
find "$DOCS_ROOT" -type d | while read dir; do
  section_title=$(basename "$dir")
  index_file="$dir/_index.md"

  cat <<EOF > "$index_file"
+++
title = "$section_title"
bookCollapseSection = true
author = "$AUTHOR"
+++

EOF

  echo "📁 생성됨: $dir"
done

# 일반 문서에 bookHidden 삽입
echo "🔧 일반 문서(bookHidden) 설정 중..."
find "$DOCS_ROOT" -type f -name "*.md" ! -name "_index.md" | while read file; do
  if ! grep -q "bookHidden" "$file"; then
    line_num=$(awk '/^\+\+\+$/ && NR>1 {print NR; exit}' "$file")
    if [ -n "$line_num" ]; then
      awk -v n="$line_num" 'NR==n{print "bookHidden = true"}{print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      echo "✅ bookHidden 삽입: $file"
    fi
  fi
done
