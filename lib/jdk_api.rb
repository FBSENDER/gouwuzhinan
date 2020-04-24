JDURI = "https://router.jd.com/api"

def jdk_system_params(method, api_key)
  {
    method: method,
    app_key: api_key,
    access_token: "",
    timestamp: Time.now.strftime("%F %T"),
    format: "json",
    v: "1.0",
    sign_method: "md5"
  }
end

def jdk_get_sign(hash, secret)
  Digest::MD5.hexdigest(hash.sort.to_a.select{|x| !x[1].nil? && x[1] != ''}.flatten.push(secret).unshift(secret).join("")).upcase!
end

def jdk_build_query(hash)
  hash.map{|key, value| "#{key}=#{value}"}.join("&")
end

def jd_union_open_goods_query(page, page_size, keyword, cid1, cid2, cid3, sku_ids, owner, sort_name, sort, is_coupon, is_pg, is_hot, shop_id, brand_code)
  pms = {
    pageIndex: page,
    pageSize: page_size,
    forbidTypes: '2,3,4,5,6,7',
    isCoupon: is_coupon.nil? || is_coupon.to_i == 0 ? 0 : 1
  }
  pms[:keyword] = keyword if keyword
  pms[:cid1] = cid1 if cid1
  pms[:cid2] = cid2 if cid2
  pms[:cid3] = cid3 if cid3
  pms[:skuIds] = sku_ids if sku_ids
  pms[:owner] = owner if owner
  pms[:sortName] = sort_name if sort_name
  pms[:sort] = sort if sort
  pms[:isPG] = is_pg if is_pg
  pms[:isHot] = is_hot if is_hot
  pms[:brandCode] = brand_code.to_s if brand_code
  pms[:shopId] = shop_id if shop_id
  sys = jdk_system_params('jd.union.open.goods.query', $jdk_app_key)
  ppp = sys.merge({param_json: {goodsReqDTO: pms}.to_json})
  my_sign = jdk_get_sign(ppp, $jdk_app_secret).upcase
  url = URI(JDURI + '?' + URI.encode(jdk_build_query(ppp.merge({sign: my_sign}))))
  Net::HTTP.get(url)
end

def jd_union_open_promotion_bysubunionid_get(item_id, position_id, coupon_url)
  pms = {
    materialId: "https://item.jd.com/#{item_id}.html",
    positionId: position_id,
    chainType: 2
  }
  if coupon_url && coupon_url != ''
    pms[:couponUrl] = coupon_url
  end
  sys = jdk_system_params('jd.union.open.promotion.bysubunionid.get', $jdk_app_key)
  ppp = sys.merge({param_json: {promotionCodeReq: pms}.to_json})
  my_sign = jdk_get_sign(ppp, $jdk_app_secret).upcase
  url = URI(JDURI + '?' + URI.encode(jdk_build_query(ppp.merge({sign: my_sign}))))
  Net::HTTP.get(url)
end

def jd_union_open_promotion_bysubunionid_get_diyurl(url, position_id)
  pms = {
    materialId: url,
    positionId: position_id,
    chainType: 2
  }
  sys = jdk_system_params('jd.union.open.promotion.bysubunionid.get', $jdk_app_key)
  ppp = sys.merge({param_json: {promotionCodeReq: pms}.to_json})
  my_sign = jdk_get_sign(ppp, $jdk_app_secret).upcase
  url = URI(JDURI + '?' + URI.encode(jdk_build_query(ppp.merge({sign: my_sign}))))
  Net::HTTP.get(url)
end
