require 'json'
data = JSON.parse(File.read('c:/Users/HomePC/AppData/Roaming/Code/User/workspaceStorage/5222ab36d016c21868848234ba93f2bc/GitHub.copilot-chat/chat-session-resources/204b6d84-0c64-4df9-982c-55403dbddaff/call_MHxWVXA5WU1nSm1NcGVuWVFGdWU__vscode-1775299151047/content.json'))
data['statusChecks'].each do |c|
  if c['state'] != 'SUCCESS'
    puts \"\n\n=== #{c['name']} ===\"
    logs = c['logs'] || ''
    puts logs.length > 2000 ? logs[-2000..-1] : logs
  end
end
