class MainService < ApplicationService

  CONTEXT_INSTRUCTION = "Na podstawie tego kontekstu:"
  INSTRUCTION = "Odpowiedz tylko na dane pytanie tak szczerze jak potrafisz"


  def initialize(message)
    @message = message
  end

  def call
    create_query
  end

  private

  def create_query

    if @message.blank?
      errors.add(:missing_param, "Brakuje wiadomości")
    else
      embed = createEmbedding(@message)
      matches = query(embed["data"][0]['embedding'])
      context = getContext(matches)
      createCompletion(@message,context)

    end
  end

  def createEmbedding(prompt)
    client = OpenAI::Client.new
    client.embeddings(
      parameters: {
        model: "text-embedding-ada-002",
        input: prompt
      }
    )
  end

  def createCompletion(prompt,context)
    client = OpenAI::Client.new
    response = client.completions(
      parameters: {
        model: "gpt-3.5-turbo-instruct",
        prompt: "#{CONTEXT_INSTRUCTION} \n\n\n Kontekst: #{context}\n\n\n#{INSTRUCTION} pytanie: \n\n\n #{prompt}",
        max_tokens: 250,
        temperature: 0.2
      })
    result = response["choices"].map { |c| c["text"]}
    return result.join().strip
  end



  def query(vector)
    pinecone = Pinecone::Client.new
    index = pinecone.index("ansai")
    result = index.query(vector: vector,
                         namespace: "ans",
                         top_k: 10,
                         include_values: false,
                         include_metadata: true)
    result["matches"].select {|match| match["score"] > 0.8}.map{|match| match["id"].to_i}
  end

  def find_messages(array)
    array.map{|mes| Message.find(mes)}
  end
  def getContext(matches)
    find_messages(matches).uniq.inject("") {|acc, m| acc + m["message"] + "\n"}
  end

end