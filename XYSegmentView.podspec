

Pod::Spec.new do |s|

  s.name             		= 'XYSegmentView'
  s.version          		= '0.9.4'
  s.summary          		= 'a custom segment component view, it decouple、elegant and efficient.'
  s.description      		= <<-DESC
								   一组可定制化的分栏组件，支持一键式配置代码。组件抽取并统一处理了基础公共代码。
								   本模块提供基类控制器，支持使用者只关心业务代码，方便实用。
		                       DESC

  s.homepage         		= 'https://github.com/xiaoyouPrince/XYSegmentView'
  s.license          		= { :type => 'MIT', :file => 'LICENSE' }
  s.author           		= { 'xiaoyouPrince' => 'xiaoyouPrince@163.com' }
  s.source           		= { :git => 'https://github.com/xiaoyouPrince/XYSegmentView.git', :tag => s.version.to_s }

  s.ios.deployment_target 	= '9.0'
  s.swift_version = '5.0'
  s.requires_arc 			= true

  s.source_files 			= 'XYSegmentView/XYSegmentView/XYSegmentView/**/*.{swift,h,m,xib}'

end
