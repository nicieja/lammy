module Lammy
  class Job
    include Sidekiq::Job

    def perform(model_name, record_id, method_name, *args)
      model_class = Object.const_get(model_name)
      record = model_class.find(record_id)
      record._lammy_perform_now do
        record.public_send(method_name, *args)
      end
    end
  end
end
