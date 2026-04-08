awk '
  /<\/dependencies>/ {
    dep_line = $0
    if (getline nextline) {
      if (nextline ~ /^[[:space:]]*<build>/) {
        while ((getline line < "email-notifier-module/email-notifier-deps.xml") > 0)
          print line
        close("email-notifier-module/email-notifier-deps.xml")
      }
      print dep_line
      print nextline
    }
    next
  }
  { print }
' phoebus-olog/pom.xml > pom.xml.tmp
awk -v repl="$EMAIL_NOTIFIER_VERSION" '{gsub(/EMAIL_NOTIFIER_VERSION/, repl); print}' pom.xml.tmp > phoebus-olog/pom.xml
rm pom.xml.tmp