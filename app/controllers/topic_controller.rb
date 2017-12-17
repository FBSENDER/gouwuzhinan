require 'topic'
class TopicController < ApplicationController
  def show
    @topic = Topic.where(id: params[:id].to_i).take
    not_found if @topic.nil? || @topic.status == 0
    @path = "/topic/#{@topic.id}/"
    if @topic.topic_type == 1
      @related_topics = Topic.select(:id, :title).sample(5)
      topic_show_1
    end
    if @topic.topic_type == 2
      @related_topics = Topic.where(topic_type: 2,status: 1).select(:id, :title).sample(5)
      topic_show_2
    end
  end

  def topic_show_1
    @coupons = JSON.parse(@topic.json_data)
    @title = @topic.title
    @desc = build_coupon_desc_1(@topic.search_keyword, @coupons)
    json_ld = {}
    json_ld["@context"] = "https://ziyuan.baidu.com/contexts/cambrian.jsonld"
    json_ld["@id"] = "http://www.gouwuzhinan.cn#{@path}"
    json_ld["appid"] = 1583226250921762
    json_ld["title"] = @title
    json_ld["images"] = @coupons.map{|c| c["thumbnail_pic"]}[0,3]
    json_ld["description"] = "#{@desc} - #{@title}"
    json_ld["pubDate"] = @topic.published_at.strftime("%FT%T")
    @json_ld = json_ld.to_json
    render "/mip/topic/topic_show_1", layout: "xiongzhang"
  end

  def topic_show_2
    data = JSON.parse(@topic.json_data)
    @coupons = data["coupons"]
    @shops = data["shops"]
    @jus = data["jus"]
    @title = @topic.title
    @desc = build_coupon_desc_2(@topic.search_keyword)
    json_ld = {}
    json_ld["@context"] = "https://ziyuan.baidu.com/contexts/cambrian.jsonld"
    json_ld["@id"] = "http://www.gouwuzhinan.cn#{@path}"
    json_ld["appid"] = 1583226250921762
    json_ld["title"] = @title
    json_ld["images"] = @coupons.map{|c| c["pict_url"]}[0,3]
    json_ld["description"] = "#{@desc} - #{@title}"
    json_ld["pubDate"] = @topic.published_at.strftime("%FT%T")
    @json_ld = json_ld.to_json
    render "/mip/topic/topic_show_2", layout: "xiongzhang"
  end

  def show_1
    @title = '龙珠超117集力量大会将现第三位自在极意功？他的崛起指日可待！'
    @coupons = JSON.parse($data)
    render "/mip/topic/topic_show_1", layout: "xiongzhang"
  end

  def build_coupon_desc_1(keyword, coupons)
    max_youhui = coupons.map{|c| c["gap_price"]}.max
    desc = "本篇为大家带来#{keyword}优惠神券，领取后，在淘宝/天猫下单时可用，最多立减#{max_youhui}元。
    #{coupons.size}张券，速度抢，手慢无，截止到发稿时余量已不多了..."
  end

  def build_coupon_desc_2(keyword)
    desc = "本篇为大家带来#{keyword}淘宝天猫优惠神券，领取后，在淘宝/天猫下单时可用。还有#{keyword}天猫旗舰店信息，以及聚划算#{keyword}打折优惠信息。为大家选购#{keyword}提供参考指南。"
  end

  $data = '[{"coupon_id":16724878,"raw_price":"24.9","coupon_price":"19.9","gap_price":5,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=2edb0a127cb84d1d8e44534712db4f06&itemId=558547141623&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u97e9\u592a \u56fd\u4ea7\u706b\u9e21\u97625\u5305","subtitle":"\u5df2\u9886 38709 \u5f20\u5238","description":"","platform_id":2,"item_id":558547141623,"store_type":0,"post_free":0,"month_sales":38709,"thumbnail_pic":"http:\/\/img.alicdn.com\/imgextra\/i3\/3246113561\/TB2L9mpj.1HTKJjSZFmXXXeYFXa_!!3246113561.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/16724878?channel=27","dateline":1512057599,"status":1,"progress":0.98,"is_new":true,"coupon_start_time":1510416000,"coupon_end_time":1512057599,"product_type":1},{"coupon_id":15406428,"raw_price":"17.8","coupon_price":"14.8","gap_price":3,"subcate_id":45,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=32e9daee2d0547729683f0cca502a92e&itemId=556679825896&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u5361\u9762 \u8d85\u503c\u4e94\u8fde\u5305\u56fd\u4ea7\u706b\u9e21\u9762 136g*5\u888b","subtitle":"\u5df2\u9886 1951 \u5f20\u5238","description":"","platform_id":1,"item_id":556679825896,"store_type":0,"post_free":1,"month_sales":1951,"thumbnail_pic":"http:\/\/file.17gwx.com\/sqkb\/coupon\/2017\/9\/25\/_1506304388672368693_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/15406428?channel=27","dateline":1514735999,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1509552000,"coupon_end_time":1514735999,"product_type":1},{"coupon_id":16786338,"raw_price":"23.6","coupon_price":"20.6","gap_price":3,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=712213d821364433be9cfaefc272378b&itemId=560094283867&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u6155\u4e1d\u59ae\u5361 \u8d85\u8fa3\u706b\u9e21\u9762140g*5","subtitle":"\u5df2\u9886 1044 \u5f20\u5238","description":"","platform_id":1,"item_id":560094283867,"store_type":0,"post_free":1,"month_sales":1044,"thumbnail_pic":"http:\/\/gaitaobao2.alicdn.com\/tfscom\/i1\/1790327615\/TB2aJ6Id_1z01JjSZFCXXXY.XXa_!!1790327615.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/16786338?channel=27","dateline":1512057599,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1511193600,"coupon_end_time":1512057599,"product_type":1},{"coupon_id":5139370,"raw_price":"26.9","coupon_price":"21.9","gap_price":5,"subcate_id":45,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=3269c08519474c0ea0f63a4c55403ebb&itemId=548496243326&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u56fd\u4ea7\u8d85\u8fa3\u8d85\u597d\u5403\u706b\u9e21\u9762 5\u8fde\u5305","subtitle":"\u5df2\u9886 2555 \u5f20\u5238","description":"\u6ee12\u4ef6\u518d\u51cf3\u5143","platform_id":1,"item_id":548496243326,"store_type":0,"post_free":1,"month_sales":2555,"thumbnail_pic":"http:\/\/omqxp8we2.bkt.clouddn.com\/coupon\/2017\/7\/4\/150172845700096235_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/5139370?channel=27","dateline":1512057599,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1509465600,"coupon_end_time":1512057599,"product_type":1},{"coupon_id":17031645,"raw_price":"21.8","coupon_price":"18.8","gap_price":3,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=faf68c332e6f4436946217e0d534b6dd&itemId=557502955152&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u6155\u4e1d\u59ae \u8d85\u8fa3\u56fd\u4ea7\u706b\u9e21\u9762 136g*5","subtitle":"\u5df2\u9886 1791 \u5f20\u5238","description":"","platform_id":1,"item_id":557502955152,"store_type":0,"post_free":1,"month_sales":1791,"thumbnail_pic":"http:\/\/gd3.alicdn.com\/imgextra\/i3\/3164609736\/TB2SaJ_XB1tLeJjSszgXXcOHpXa_!!3164609736.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/17031645?channel=27","dateline":1511452799,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1510934400,"coupon_end_time":1511452799,"product_type":1},{"coupon_id":16279055,"raw_price":"50.0","coupon_price":"35.0","gap_price":15,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=d1e4b4bf85c34fb691be35b25416cc51&itemId=558755553034&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u97e9\u592a \u56fd\u4ea7\u706b\u9e21\u9762 10\u5305","subtitle":"\u5df2\u9886 332 \u5f20\u5238","description":"","platform_id":2,"item_id":558755553034,"store_type":0,"post_free":0,"month_sales":332,"thumbnail_pic":"http:\/\/img.alicdn.com\/imgextra\/i2\/3246113561\/TB2.6haXGigSKJjSsppXXabnpXa_!!3246113561.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/16279055?channel=27","dateline":1511452799,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1511107200,"coupon_end_time":1511452799,"product_type":1},{"coupon_id":17610868,"raw_price":"27.8","coupon_price":"17.8","gap_price":10,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=87b26ea22c0a40e9871ee78129bceca9&itemId=560578199638&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u4e09\u517b \u97e9\u56fd\u8fdb\u53e3\u8d85\u8fa3\u706b\u9e21\u9762\u65b9\u4fbf\u9762 140g*5\u5305","subtitle":"\u5df2\u9886 10 \u5f20\u5238","description":"\u8d85\u4f4e\u4ef7\u683c \u9650\u65f6\u62a2\u8d2d","platform_id":1,"item_id":560578199638,"store_type":0,"post_free":1,"month_sales":10,"thumbnail_pic":"http:\/\/gd1.alicdn.com\/imgextra\/i1\/837289906\/TB2HUyeXlfH8KJjy1XbXXbLdXXa_!!837289906.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/17610868?channel=27","dateline":1511539199,"status":1,"progress":0.98,"is_new":true,"coupon_start_time":1511280000,"coupon_end_time":1511539199,"product_type":1},{"coupon_id":12323780,"raw_price":"23.8","coupon_price":"18.8","gap_price":5,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=ea0b97b305f74c7596bc4d6ca73cbe65&itemId=548243762382&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u56fd\u4ea7\u706b\u9e21\u9762\u8d85\u8fa3\u65b9\u4fbf\u9762 140g*5\u5305","subtitle":"\u5df2\u9886 249 \u5f20\u5238","description":"\u6700\u540e\u4e00\u5929\u4f18\u60e0","platform_id":1,"item_id":548243762382,"store_type":0,"post_free":0,"month_sales":249,"thumbnail_pic":"http:\/\/gaitaobao3.alicdn.com\/tfscom\/i2\/761829236\/TB2SiU5mgxlpuFjy0FoXXa.lXXa_!!761829236.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/12323780?channel=27","dateline":1512057599,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1508947200,"coupon_end_time":1512057599,"product_type":1},{"coupon_id":14358157,"raw_price":"46.8","coupon_price":"36.8","gap_price":10,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=a4ce79c5c8e440a2bfb97fa248669972&itemId=555961558249&pid=mm_114743487_34002001_120838880&nowake=1","title":"\u767d\u8c61 \u5e72\u62cc\u9762\u56db\u53e3\u5473\u516b\u7897\u7ec4\u5408\u88c5","subtitle":"\u5df2\u9886 5608 \u5f20\u5238","description":"","platform_id":2,"item_id":555961558249,"store_type":0,"post_free":1,"month_sales":5608,"thumbnail_pic":"http:\/\/img.alicdn.com\/imgextra\/i1\/2360794809\/TB2xsIGbrMlyKJjSZFAXXbkLXXa_!!2360794809.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/14358157?channel=27","dateline":1511539199,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1511280000,"coupon_end_time":1511539199,"product_type":1},{"coupon_id":15878876,"raw_price":"27.8","coupon_price":"22.8","gap_price":5,"subcate_id":47,"url":"https:\/\/uland.taobao.com\/coupon\/edetail?tj1=1&tj2=1&activityId=1d9b2df47f034d868d9a7e90a6153536&itemId=558265866458&pid=mm_114743487_34002001_120838880&nowake=1","title":"EGO \u706b\u9e21\u9762\u8d85\u8fa3140g*5\u5305","subtitle":"\u5df2\u9886 8384 \u5f20\u5238","description":"","platform_id":2,"item_id":558265866458,"store_type":0,"post_free":0,"month_sales":8384,"thumbnail_pic":"http:\/\/img.alicdn.com\/imgextra\/i2\/2102198181\/TB2QS_6d1kJL1JjSZFmXXcw0XXa_!!2102198181.jpg_400x400","detail_url":"http:\/\/m.ibantang.com\/zhekou\/15878876?channel=27","dateline":1511884799,"status":1,"progress":0.98,"is_new":false,"coupon_start_time":1511193600,"coupon_end_time":1511884799,"product_type":1}]'
end
