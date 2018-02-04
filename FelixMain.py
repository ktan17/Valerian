# Imports the Google Cloud client library
from google.cloud import language
from google.cloud.language import enums
from google.cloud.language import types
from watson_developer_cloud.tone_analyzer_v3 import*
import boto3
import os, six, sys, json
import datetime, time, calendar

with open("/Users/alanyuen/Desktop/Felix/NOTHING_TO_SEE_HERE.txt", "r") as f:
	lines = f.readlines()
	google_creds_key =lines[0].rstrip()
	WatsonUsername = lines[1].rstrip()
	WatsonPassword = lines[2].rstrip()

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = google_creds_key

entity_type = ('UNKNOWN', 'PERSON', 'LOCATION', 'ORGANIZATION',
				'EVENT', 'WORK_OF_ART', 'CONSUMER_GOOD', 'OTHER')


#*--------------------------------------------------------------------------------------------*#

def entity_sentiment_text(text):
	"""Detects entity sentiment in the provided text."""
	client = language.LanguageServiceClient()

	if isinstance(text, six.binary_type):
		text = text.decode('utf-8')

	result = []
	for sentence in text:
		document = types.Document(
				content=sentence.encode('utf-8'),
				type=enums.Document.Type.PLAIN_TEXT)

		# Detect and send native Python encoding to receive correct word offsets.
		encoding = enums.EncodingType.UTF32
		if sys.maxunicode == 65535:
			encoding = enums.EncodingType.UTF16

		result.append(client.analyze_entity_sentiment(document, encoding))
	return result

def detect_key_phrases(text):
	text = ".".join(text)
	comprehend = boto3.client(service_name='comprehend', region_name='us-west-2')
	
	#entities = comprehend.detect_entities(Text=text, LanguageCode='en')
	#print(json.dumps(entities,  sort_keys=True, indent=4))

	keyphrases = comprehend.detect_key_phrases(Text=text, LanguageCode='en')

	#print(json.dumps(keyphrases, sort_keys=True, indent=4))
	return keyphrases


def sentiment_text(text):
	"""Detects sentiment in the text."""
	client = language.LanguageServiceClient()

	if isinstance(text, six.binary_type):
		text = text.decode('utf-8')

	# Instantiates a plain text document.
	document = types.Document(content=text,type=enums.Document.Type.PLAIN_TEXT)

	# Detects sentiment in the document. You can also analyze HTML with:
	#   document.type == enums.Document.Type.HTML
	sentiment = client.analyze_sentiment(document).document_sentiment

	return [sentiment.score , sentiment.magnitude]

def analyze_tone(text):
	tone_analyzer = ToneAnalyzerV3(
			version='2017-09-21',
			username = WatsonUsername,
			password = WatsonPassword
			)

	tone = tone_analyzer.tone({ "text" : ".".join(text) })#dict
	print(json.dumps(tone, indent=2))
	with open('data.json', 'w') as fp:
	    json.dump(tone, fp)
	return tone


def insert_data(sentences, keyphrases, tones, text):
	"""
	Sentences (SIDs)
	{
		00000000001 :
		{
			content : "I like pie",
			sentiment_score: 0.0,
			sentiment_magnitude: 0.0,
			time_stamp: 32190321,
		}

		00000000002 :
		{
			...
		}

		...
	}
	"""
	client = language.LanguageServiceClient()

	if isinstance(text, six.binary_type):
		text = text.decode('utf-8')

	
	if(len(sentences["Sentences"]) == 0):
		sentence_id_offset = 0
	else:
		sentence_id_offset = max(list(sentences["Sentences"].keys())) + 1

	text_sentences = text.split(".")[:-1]
	for i in range(len(text_sentences)):
		text_sentences[i] = text_sentences[i].lstrip()
		document = types.Document(content=text_sentences[i],type=enums.Document.Type.PLAIN_TEXT)
		detected_sentiment = client.analyze_sentiment(document).document_sentiment
		sentences["Sentences"][sentence_id_offset+i] = 	{
															"content" : text_sentences[i],
															"sentiment_score" : detected_sentiment.score,
															"sentiment_magnitude" : detected_sentiment.magnitude,
															"timestamp" : datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')
														} 
	"""
	Keyphrases (KPIDs)
	{
		00000000001 :
		{
			SID: 00000000132
			content : "school", #remember to lowercase all text
			salience : 0.5
		}

		00000000002 :
		{
			...
		}

	...
	}
	"""				
	comprehend = boto3.client(service_name='comprehend', region_name='us-west-2')
	
	#entities = comprehend.detect_entities(Text=text, LanguageCode='en')
	#print(json.dumps(entities,  sort_keys=True, indent=4))
	for i in range(len(text_sentences)):
		detected_key_phrases = comprehend.detect_key_phrases(Text=text_sentences[i], LanguageCode='en')
		keyphrase_entries = [{ 
								"SID" : (sentence_id_offset + i),
								"Text" : detected_key_phrases["KeyPhrases"][j]["Text"],
								"Score" : detected_key_phrases["KeyPhrases"][j]["Score"]
							} for j in range(len(detected_key_phrases["KeyPhrases"]))]

		keyphrases["KeyPhrases"] += keyphrase_entries

	"""
	Tones (SIDs)
		{
			00000000003 :
			{
				tone_id : 1,
				score : 0.0
			}
	
			...
		}
	"""

	tone_analyzer = ToneAnalyzerV3(
			version='2017-09-21',
			username = WatsonUsername,
			password = WatsonPassword
			)
	print(text)
	tone = tone_analyzer.tone({"text" : text })#dict
	#print(json.dumps(tone,indent = 2))
	shift = 0
	i = 0
	while i < len(tone["sentences_tone"]):
		while(text_sentences[i+shift] not in tone["sentences_tone"][i]["text"]):
			shift += 1
		tones["Tones"][sentence_id_offset+i+shift] = [{
											"tone_id" : tone["sentences_tone"][i]["tones"][j]["tone_id"],
											"score" : tone["sentences_tone"][i]["tones"][j]["score"]
										} for j in range(len(tone["sentences_tone"][i]["tones"]))]
		i+=1

	"""
	MetaData
	{
		DailyTones :
		{
			content : "I like pie",
			sentiment_score: 0.0,
			sentiment_magnitude: 0.0,
			time_stamp: 32190321
		}

		WeeklyTones :
		{
			"Tones" :
			{
				00000000003 :
				{
					tone_id : 1,
					score : 0.0
				}
		
				...
			},
			"AverageJoy" :
			{
				"average_value" : 0.0,
				""
			}
		}

		...
	}
	"""

#													RUNS API
#*--------------------------------------------------------------------------------------------*#
sentences = {"Sentences": {}}
keyphrases = {"KeyPhrases": []}
tones = {"Tones": {}}

# bad_text = "I said something wrong at a social event. I felt embarrassed and later I was anxious thinking about it. I feel like a failure. I worry that people will judge me. I hate that I feel this way inside, and that I’m always making dumb mistakes."
# good_text  = "It's okay if I make mistakes. I have some strengths that people appreciate. I want to get rid of this negative thinking. I feel better when I am kind to myself."
# bad_text2 = "I failed my test. I can't believe I am so careless. I should have studied more, but I didn't because I'm lazy. I won't get into the college I really want to get into."
# good_text2 = "The next time I make a mistake, I won't dwell on the negatives. I will remind myself of my past successes. I will remember to be kind to myself and to others."

text = "Insert Text Here"
insert_data(sentences, keyphrases, tones, text)

"""
	DailyJoy %: 0.2327391110194038
	DailySadness %: 0.1317459084252313
	DailyAnger %: 0.0
	DailyAnxiety %: 0.0
	DailyTentative %: 0.23777130801441795
	DailyConfidence %: 0.0
	DailyAnalytical %: 0.3977436725409469
"""
"""
	DailyJoy %: 0.0
	DailySadness %: 0.29244234030887645
	DailyAnger %: 0.0736758904323269
	DailyAnxiety %: 0.17077570662441838
	DailyTentative %: 0.19866165957937207
	DailyConfidence %: 0.0
	DailyAnalytical %: 0.26444440305500616
"""

print(json.dumps(sentences,indent=2))
print(json.dumps(keyphrases,indent=2))
print(json.dumps(tones,indent=2))


#*--------------------------------------------------------------------------------------------*#

#					USES STORED DATA
#*--------------------------------------------------------------------------------------------*#
# with open('sentences.json', 'w') as outfile:
#     json.dump(sentences, outfile)
# with open('keyphrases.json', 'w') as outfile:
#     json.dump(keyphrases, outfile)
# with open('tones.json', 'w') as outfile:
#     json.dump(tones, outfile)

# with open("/Users/alanyuen/Desktop/Felix/sentences.json") as text_json:
# 	text_j = text_json.read()
# 	sentences = json.loads(text_j)
# with open("/Users/alanyuen/Desktop/Felix/keyphrases.json") as text_json:
# 	text_j = text_json.read()
# 	keyphrases = json.loads(text_j)
# with open("/Users/alanyuen/Desktop/Felix/tones.json") as text_json:
# 	text_j = text_json.read()
# 	tones = json.loads(text_j)

# print(json.dumps(sentences,indent=2))
# print(json.dumps(keyphrases,indent=2))
# print(json.dumps(tones,indent=2))
#*--------------------------------------------------------------------------------------------*#
metadata = {
				"Today" : "2018-02-04",
				"DailySentiment" : [0.0 , 0],
				"DailyJoy" : [0.0 , 0],
				"DailySadness" : [0.0 , 0],
				"DailyAnxiety" : [0.0 , 0],
				"DailyAnger" : [0.0 , 0],
				"DailyTentative" : [0.0 , 0],
				"DailyConfidence" : [0.0 , 0],
				"DailyAnalytical" : [0.0 , 0]
			}

weekly_history = {[
					{
						"DailySentiment" : [0.0 , 0],
						"DailyJoy" : [0.0 , 0],
						"DailySadness" : [0.0 , 0],
						"DailyAnxiety" : [0.0 , 0],
						"DailyAnger" : [0.0 , 0],
						"DailyTentative" : [0.0 , 0],
						"DailyConfidence" : [0.0 , 0],
						"DailyAnalytical" : [0.0 , 0]
					} for i in range(7)
				]}


def calc_daily_sentiment(sentences, metadata):
	total_sentiment = 0
	num_sentences_today = 0
	for SID in reversed(list(sentences["Sentences"])):
		if(metadata["Today"] == sentences["Sentences"][SID]["timestamp"][:10]):
			sentiment_score = sentences["Sentences"][SID]["sentiment_score"]
			metadata["DailySentiment"][0] = sentiment_score
			metadata["DailySentiment"][1] += 1
	print(metadata["DailySentiment"][0] / float(metadata["DailySentiment"]))

def calc_daily_tones(sentences, metadata):
	for SID in reversed(list(tones["Tones"])):
		if(metadata["Today"] == sentences["Sentences"][SID]["timestamp"][:10]):

			for t in tones["Tones"][SID]:
				emotion_score = t["score"]
				if(t["tone_id"] == "joy"):
					metadata_title = "DailyJoy"
				elif(t["tone_id"] == "sadness"):
					metadata_title = "DailySadness"
				elif(t["tone_id"] == "anger"):
					metadata_title = "DailyAnger"
				elif(t["tone_id"] == "fear"):
					metadata_title = "DailyAnxiety"
				elif(t["tone_id"] == "tentative"):
					metadata_title = "DailyTentative"
				elif(t["tone_id"] == "confidence"):
					metadata_title = "DailyConfidence"
				elif(t["tone_id"] == "analytical"):
					metadata_title = "DailyAnalytical"

				metadata[metadata_title][0] += t["score"]
				metadata[metadata_title][1] += 1
#2012-12-15 01:21:05
"""
def calc_weekly_tones(sentences, metadata):

	
	todays_date = ""
	current_year = int(todays_date[:4])
	current_month = int(todays_date[5:7])
	week_ago_date = todays_date - 7 + calendar.monthrange(current_year,current_month)[1]

	for SID in reversed(list(tones["Tones"])):
		
		this_day = int(sentences["Sentences"][SID]["timestamp"][8:10])
		this_month
		if(current_month this_day < 
		if(metadata["Today"] == sentences["Sentences"][SID]["timestamp"][:10]):
			for t in tones["Tones"][SID]:
				emotion_score = t["score"]
				if(t["tone_id"] == "joy"):
					metadata_title = "DailyJoy"
				elif(t["tone_id"] == "sadness"):
					metadata_title = "DailySadness"
				elif(t["tone_id"] == "anger"):
					metadata_title = "DailyAnger"
				elif(t["tone_id"] == "fear"):
					metadata_title = "DailyAnxiety"
				elif(t["tone_id"] == "tentative"):
					metadata_title = "DailyTentative"
				elif(t["tone_id"] == "confidence"):
					metadata_title = "DailyConfidence"
				elif(t["tone_id"] == "analytical"):
					metadata_title = "DailyAnalytical"

				metadata[metadata_title][0] += t["score"]
				metadata[metadata_title][1] += 1
"""
# ["DailyJoy","DailySadness","DailyAnger","DailyAnxiety","DailyTentative","DailyConfidence","DailyAnalytical"]
def normalize_main_emo(metadata):
	emos = ["DailyJoy","DailySadness","DailyAnger","DailyAnxiety","DailyTentative","DailyConfidence","DailyAnalytical"]
	total = 0
	for emo in emos:
		total += metadata[emo][0]
	for emo in emos:
		print("{} %: {}".format(emo, metadata[emo][0]/float(total)))

normalize_main_emo(metadata)


#*--------------------------------------------------------------------------------------------*#



#*--------------------------------------------------------------------------------------------*#

	#indices = [i for i, x in enumerate(text) if x == "."]
	# for entity in result.entities:
	# 	if(entity.name not in keyphrases):
	# 		keyphrases[entity.name] = []

	# 	sentence_ids = []

	# 	for mention in entity.mentions:

	# 		sentence_ids += [0]
	# 		for i in range(len(indices)):
	# 			if(mention.text.begin_offset < indices[i]):
	# 			sentence_ids[-1] = i
	# 			break

	# 	#Keyphrase[entity.name] = [salience, sentiment score, sentiment magnitude, entity type]
	# 	keyphrases[entity.name].append([sentence_ids, entity.salience, entity.sentiment.score, entity.sentiment.magnitude, entity_type[entity.type]])
	# #print(keyphrases)

# with open("/content/drive/Colab/FelixData/tone.json") as tone_json:
# 	text_json = tone_json.read()
# 	data_json = json.loads(text_json)

# print(data_json["document_tone"])
# print("\n")

#entity_sentiment_text("Dan's parents were overweight. Dan was overweight as well. The doctors told his parents it was unhealthy. His parents understood and decided to make a change.")


