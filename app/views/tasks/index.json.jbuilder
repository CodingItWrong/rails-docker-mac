json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :notes, :due, :completion
  json.url task_url(task, format: :json)
end
