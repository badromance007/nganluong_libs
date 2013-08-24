#!/usr/bin/ruby
require 'digest/md5'
require 'uri'

# Add URL Encoding
class String
  def urlencoding
    URI.escape( self, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]") )
  end
end

class Nganluong_checkout
  NL_URL = 'https://www.nganluong.vn/checkout.php'

  # Mã website của bạn đăng ký trong chức năng tích hợp thanh toán của NgânLượng.vn.
  MERCHANT_SITE_CODE = '29716'

  # Mật khẩu giao tiếp giữa website của bạn và NgânLượng.vn.
  SECURE_PASS= 'lam!@#vcc'

  # Mã đối tác tham gia chương trình liên kết của NgânLượng.vn
  AFFILIATE_CODE = ''

  ## HÀM TẠO ĐƯỜNG LINK THANH TOÁN QUA NGÂNLƯỢNG.VN VỚI THAM SỐ MỞ RỘNG
   #
   # @param string return_url: Đường link dùng để cập nhật tình trạng hoá đơn tại website của bạn khi người mua thanh toán thành công tại NgânLượng.vn
   # @param string receiver: Địa chỉ Email chính của tài khoản NgânLượng.vn của người bán dùng nhận tiền bán hàng
   # @param string transaction_info: Tham số bổ sung, bạn có thể dùng để lưu các tham số tuỳ ý để cập nhật thông tin khi NgânLượng.vn trả kết quả về
   # @param string order_code: Mã hoá đơn hoặc tên sản phẩm
   # @param int price: Tổng tiền hoá đơn/sản phẩm, chưa kể phí vận chuyển, giảm giá, thuế.
   # @param string currency: Loại tiền tệ, nhận một trong các giá trị 'vnd', 'usd'. Mặc định đồng tiền thanh toán là 'vnd'
   # @param int quantity: Số lượng sản phẩm
   # @param int tax: Thuế
   # @param int discount: Giảm giá
   # @param int fee_cal: Nhận giá trị 0 hoặc 1. Do trên hệ thống NgânLượng.vn cho phép chủ tài khoản cấu hình cho nhập/thay đổi phí lúc thanh toán hay không. Nếu website của bạn đã có phí vận chuyển và không cho sửa thì đặt tham số này = 0
   # @param int fee_shipping: Phí vận chuyển
   # @param string order_description: Mô tả về sản phẩm, đơn hàng
   # @param string buyer_info: Thông tin người mua 
   # @param string affiliate_code: Mã đối tác tham gia chương trình liên kết của NgânLượng.vn
   # @return string
  ##

  def build_checkout_url_expand(return_url, receiver, transaction_info,
                                order_code, price, currency = 'vnd', 
                                quantity = 1, tax = 0, discount = 0, 
                                fee_cal = 0, fee_shipping = 0, order_description = '', 
                                buyer_info = '', affiliate_code = ''
                              )
    affiliate_code = AFFILIATE_CODE if affiliate_code == ''

    params = Hash[
      'merchant_site_code' =>  MERCHANT_SITE_CODE.to_s,
      'return_url'         =>  return_url.to_s.downcase,
      'receiver'           =>  receiver.to_s,
      'transaction_info'   =>  transaction_info.to_s,
      'order_code'         =>  order_code.to_s,
      'price'              =>  price.to_s,
      'currency'           =>  currency.to_s,
      'quantity'           =>  quantity.to_s,
      'tax'                =>  tax.to_s,
      'discount'           =>  discount.to_s,
      'fee_cal'            =>  fee_cal.to_s,
      'fee_shipping'       =>  fee_shipping.to_s,
      'order_description'  =>  order_description.to_s,
      'buyer_info'         =>  buyer_info.to_s,
      'affiliate_code'     =>  affiliate_code.to_s
      ]

    secure_code = params.map { |k, v| "#{v}" }.join(' ')
    secure_code += ' '+SECURE_PASS

    params['secure_code'] = Digest::MD5.hexdigest( secure_code )

    redirect_url = NL_URL
    
    # Kiểm tra  biến redirect_url xem có '?' không, nếu không có thì bổ sung vào    
    if ( !redirect_url.index('?') )
      redirect_url += '?'
    # Nếu biến redirect_url có '?' nhưng không kết thúc bằng '?' và có chứa dấu '&' thì bổ sung vào cuối
    elsif ( redirect_url[-1] != '?' &&  !redirect_url.index('&') )
      redirect_url += '&'
    end

    url = ''
    params.each do |k, v|
      v = v.urlencoding if k != 'return_url'
      if url != ''
        url += '&'+k+'='+v
      else
        url += k+'='+v
      end
    end

    return redirect_url + url
  end

  ## HÀM TẠO ĐƯỜNG LINK THANH TOÁN QUA NGÂNLƯỢNG.VN VỚI THAM SỐ CƠ BẢN
   #
   # @param string return_url: Đường link dùng để cập nhật tình trạng hoá đơn tại website của bạn khi người mua thanh toán thành công tại NgânLượng.vn
   # @param string receiver: Địa chỉ Email chính của tài khoản NgânLượng.vn của người bán dùng nhận tiền bán hàng
   # @param string transaction_info: Tham số bổ sung, bạn có thể dùng để lưu các tham số tuỳ ý để cập nhật thông tin khi NgânLượng.vn trả kết quả về
   # @param string order_code: Mã hoá đơn hoặc tên sản phẩm
   # @param int price: Tổng tiền hoá đơn/sản phẩm, chưa kể phí vận chuyển, giảm giá, thuế.
   # @return string
  ##

  def build_checkout_url(return_url, receiver, transaction_info,
                        order_code, price
                      )

    params = Hash[
      'merchant_site_code' =>  MERCHANT_SITE_CODE.to_s,
      'return_url'         =>  return_url.urlencoding.to_s.downcase,
      'receiver'           =>  receiver.to_s,
      'transaction_info'   =>  transaction_info.to_s,
      'order_code'         =>  order_code.to_s,
      'price'              =>  price.to_s
    ]

    secure_code = params.map { |k, v| "#{v}" }.join(' ')
    secure_code += ' '+SECURE_PASS

    params['secure_code'] = Digest::MD5.hexdigest( secure_code )

    redirect_url = NL_URL
    
    # Kiểm tra  biến redirect_url xem có '?' không, nếu không có thì bổ sung vào    
    if ( !redirect_url.index('?') )
      redirect_url += '?'
    # Nếu biến redirect_url có '?' nhưng không kết thúc bằng '?' và có chứa dấu '&' thì bổ sung vào cuối
    elsif ( redirect_url[-1] != '?' &&  !redirect_url.index('&') )
      redirect_url += '&'
    end

    url = ''
    params.each do |k, v|
      v = v.urlencoding if k != 'return_url'
      if url != ''
        url += '&'+k+'='+v
      else
        url += k+'='+v
      end
    end

    return redirect_url + url
  end

  ##
   # HÀM KIỂM TRA TÍNH ĐÚNG ĐẮN CỦA ĐƯỜNG LINK KẾT QUẢ TRẢ VỀ TỪ NGÂNLƯỢNG.VN
   #
   # @param string transaction_info: Thông tin về giao dịch, Giá trị do website gửi sang
   # @param string order_code: Mã hoá đơn/tên sản phẩm
   # @param string price: Tổng tiền đã thanh toán
   # @param string payment_id: Mã giao dịch tại NgânLượng.vn
   # @param int payment_type: Hình thức thanh toán: 1 - Thanh toán ngay (tiền đã chuyển vào tài khoản NgânLượng.vn của người bán); 2 - Thanh toán Tạm giữ (tiền người mua đã thanh toán nhưng NgânLượng.vn đang giữ hộ)
   # @param string error_text: Giao dịch thanh toán có bị lỗi hay không. error_text == "" là không có lỗi. Nếu có lỗi, mô tả lỗi được chứa trong error_text
   # @param string secure_code: Mã checksum (mã kiểm tra)
   # @return unknown
  ##

  def verify_payment_url(transaction_info, order_code, price, payment_id,
                        payment_type, error_text, secure_code
                      )
    str = ''
    str += ' '+transaction_info.to_s
    str += ' '+order_code.to_s
    str += ' '+price.to_s
    str += ' '+payment_id.to_s
    str += ' '+payment_type.to_s
    str += ' '+error_text.to_s
    str += ' '+MERCHANT_SITE_CODE.to_s
    str += ' '+SECURE_PASS.to_s

    verify_secure_code = Digest::MD5.hexdigest( str )

    if verify_secure_code == secure_code
      return true
    else
      return false
    end
  end
  
end