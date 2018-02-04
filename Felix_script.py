introduction = "Hi. My name is Felix! I am here to help you exercise healthy ways of thinking, through a process called cognitive behavioural therapy (CBT). This method is proven to be one of the best options to improve daily mood and overall health. I am also attentative of the meaning of your words in order to help you identify thought patterns and keep track of your mood day-to-day. You can think of me as a tool to help you tackle the difficult task of identifying the many negative automatic thoughts we all experience so often. I am always available and everything in our conversation will be kept private and anonymous, so feel free to message me anytime and talk to me about anything that's on your mind."

what_is_CBT = "Cognitive behavioural therapy (CBT) is a mental exercise proven to be one of the best methods to improve daily mood and overall health. The key steps in CBT is to: identify and get to know automatic negative thoughts that are spontaneously triggered, ask whether there is concrete evidence or good reason to feel the way you do, challenge your initial thoughts by doubting your instincts, and find an alternative to view the thought or situation."

cbt_prompts = [	"(Free Prompt / Warm-up) What's on your mind?",
				"(Identifying automatic thought) What thought first crossed your mind? This was probably a subconscious or automatic thought that you have had before.",
				"(Challenge your automatic thought) What facts do you have that support or challenge your initial thought?",
				"(Exercise alternative thinking) How could you re-write your thoughts into a different perspective?"]


print(introduction)
print()
print(what_is_CBT)

command_keywords = ["help"]

probing = True
current_prompt_id = 0

user_response = []

while(probing):

	user_input = input(cbt_prompts[current_prompt_id]+"\n")

	if(user_input in command_keywords):
		#check if response is a keyword for re-direction of dialogue
		print(what_is_CBT)
	else:
		#if response is not part of keyword, it assumes it is a response to the cbt prompt
		user_response.append(user_input)
		current_prompt_id += 1

	if(current_prompt_id > len(cbt_prompts)):
		probing = False

