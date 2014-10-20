require 'bosonnlp'

# --------------------------------------------
# run `export BOSON_API_TOKEN="<your token from bosonnlp.com>"` first.
p '美好'.c_sentiment
p ['美好', '悲惨'].c_sentiment

p ['很好吃, 有点贵', '贵了点, 好吃',
   '价格贵, 但很好吃', '很好吃, 但很贵'].m_comments

p ['病毒式媒体网站：让新闻迅速蔓延'].s_keywords

# -----------------------------------------
# You can pass your token like `Bosonnlp.new("<your token from bosonnlp.com>")`
nlp = Bosonnlp.new

p nlp.c_sentiment(['美好','悲惨'])
p nlp.c_ner(['对于该小孩是不是郑尚金的孩子，目前已做亲子鉴定，结果还没出来，',\
             '纪检部门仍在调查之中。成都商报记者 姚永忠'])
p nlp.c_depparser(['我以最快的速度吃了午饭', '先留长头发再剃个秃子'])
p nlp.c_tag(['这个世界好复杂', '计算机是科学么'])
p nlp.c_classify(['俄否决安理会谴责叙军战机空袭阿勒颇平民',
                  '邓紫棋谈男友林宥嘉：我觉得我比他唱得好',
                  'Facebook收购印度初创公司'])

# ------------ mutiple texts API ------------------
p nlp.m_cluster(['今天天气好', '今天天气好', '今天天气不错', '点点楼头细雨',\
                 '重重江外平湖', '当年戏马会东徐', '今日凄凉南浦'])
p nlp.m_comments(['很好吃, 有点贵', '贵了点, 好吃',
                  '价格贵, 但很好吃', '很好吃, 但很贵'])

# --- mannaly push mutiple times for large amount of texts. ---
mh = nlp.create_multiple(:comments)
mh.push(['很好吃, 有点贵', '贵了点, 好吃'])
mh.push(['价格贵, 但很好吃', '很好吃, 但很贵'])
mh.analysis  # Will cost some time on server side.
p mh.result  # Will block until get result from server.

mh.push(['很好吃, 有点贵', '贵了点, 好吃']) #  Yes, do it incrementally!
mh.analysis
p mh.result

mh.clear  # clear the texts.

# -------------------------------------
#p nlp.s_time(['2013年二月二十八日下午四点三十分二十九秒'])
p nlp.s_keywords(['病毒式媒体网站：让新闻迅速蔓延'])
#-------------- with query --------
query = { 'top_k' => 3 }
p nlp.s_suggest(['粉丝'], :query => query)
