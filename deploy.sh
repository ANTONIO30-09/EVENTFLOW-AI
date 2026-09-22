#!/bin/bash
cd "$(dirname "$0")"
if [ -z "$GROQ_API_KEY" ]; then
  echo "ERROR: Falta la variable GROQ_API_KEY"
  exit 1
fi
flutter build web --dart-define=GROQ_API_KEY=$GROQ_API_KEY
firebase deploy --only hosting
