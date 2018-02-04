import sys
import json

data = sys.argv[1] + " and kevin is kool too!"
jsonData = json.dumps({"success": True, "message": data}, separators=(',',':'))
print(jsonData)
sys.stdout.flush()
