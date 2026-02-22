import ai.koog.agents.core.agent.AIAgent
import ai.koog.agents.core.agent.config.AIAgentConfig
import ai.koog.agents.core.dsl.builder.forwardTo
import ai.koog.agents.core.dsl.builder.strategy
import ai.koog.agents.core.dsl.extension.nodeLLMRequestStructured
import ai.koog.agents.core.tools.annotations.LLMDescription
import ai.koog.prompt.dsl.prompt
import ai.koog.prompt.executor.clients.openai.OpenAIModels
import ai.koog.prompt.executor.llms.all.simpleOpenAIExecutor
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// ---------------------------------------------------------------------------
// Data class that defines the SHAPE of the response we want from the LLM.
// ---------------------------------------------------------------------------
// Instead of getting free text like "Tokyo is the capital of Japan...",
// the LLM will return a JSON object that Koog deserializes into this class.
// You then access fields directly: analysis.city, analysis.populationMillions, etc.
//
// @Serializable       -- required by Kotlin serialization (handles JSON conversion)
// @SerialName("...")   -- the name sent to the LLM in the schema
// @LLMDescription      -- tells the LLM what each field means (on a class or property)
// @property:LLMDescription -- same, but the "property:" prefix is needed for
//                            data class constructor parameters (a Kotlin quirk)
// ---------------------------------------------------------------------------

@Serializable
@SerialName("CityAnalysis")
@LLMDescription("An analysis of a city covering key facts and livability")
data class CityAnalysis(
    @property:LLMDescription("Name of the city")
    val city: String,

    @property:LLMDescription("Country where the city is located")
    val country: String,

    @property:LLMDescription("Approximate population in millions")
    val populationMillions: Double,

    @property:LLMDescription("The city's primary language")
    val primaryLanguage: String,

    @property:LLMDescription("Three notable landmarks or attractions")
    val landmarks: List<String>,

    @property:LLMDescription("A short summary of the city's character in one or two sentences")
    val summary: String,
)

// ---------------------------------------------------------------------------
// Agent with a structured output strategy
// ---------------------------------------------------------------------------

suspend fun main() {
    val apiKey = System.getenv("OPENAI_API_KEY")
        ?: error("Set the OPENAI_API_KEY environment variable before running this example.")

    // A "strategy" is a graph that tells Koog how to process the request.
    // This one has two nodes:
    //   1. preparePrompt -- passes the user's input string through unchanged
    //   2. getStructured -- sends it to the LLM and parses the response into CityAnalysis
    //
    // Think of it as a pipeline:  input -> prepare -> LLM (structured) -> output
    val structuredStrategy = strategy<String, CityAnalysis>("city-analysis") {
        val preparePrompt by node<String, String> { input -> input }

        val getStructured by nodeLLMRequestStructured<CityAnalysis>()

        // Wire the nodes together: start -> prepare -> structured -> finish
        nodeStart then preparePrompt then getStructured
        edge(getStructured forwardTo nodeFinish transformed { it.getOrThrow().data })
    }

    val agentConfig = AIAgentConfig(
        prompt = prompt("city-analyst") {
            system("You are a knowledgeable city analyst. When asked about a city, provide accurate structured data.")
        },
        model = OpenAIModels.Chat.GPT4o,
        maxAgentIterations = 5,
    )

    simpleOpenAIExecutor(apiKey).use { executor ->
        val agent = AIAgent(
            promptExecutor = executor,
            strategy = structuredStrategy,
            agentConfig = agentConfig,
        )

        // The return type is CityAnalysis -- a real Kotlin object, not a string.
        // No JSON parsing or regex extraction needed in your code.
        val analysis: CityAnalysis = agent.run("Tell me about Tokyo")

        // Access typed fields directly
        println("City: ${analysis.city}")
        println("Country: ${analysis.country}")
        println("Population: ${analysis.populationMillions}M")
        println("Language: ${analysis.primaryLanguage}")
        println("Landmarks: ${analysis.landmarks.joinToString(", ")}")
        println("Summary: ${analysis.summary}")
    }
}
