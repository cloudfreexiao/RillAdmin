return {
	-- 白名单配置：不需要登录即可访问；除非要二次开发，否则不应更改
	whitelist = {
		"^/api/login$", -- login page
		"^/api/sign_up$", -- sign up page
		-- "^/api/user$",
		"^/error/$" -- error page
	},

	-- 静态模板配置，保持默认不修改即可
	view_config = {
		engine = "tmpl",
		ext = "html",
		views = "./app/views"
	},


	-- 分页时每页条数配置
	page_config = {
		index_topic_page_size = 10, -- 首页每页文章数
	},



	-- ########################## 以下配置需要使用者自定义为本地需要的配置 ########################## --

	-- 生成session的secret，请一定要修改此值为一复杂的字符串，用于加密session
	session_secret = "3584827dfed45b40328acb6242bhngod",

	-- 用于存储密码的盐，请一定要修改此值, 一旦使用不能修改，用户也可自行实现其他密码方案
	pwd_secret = "salt_secret_for_password", 
	jwt_secret = "hjuhdk_jjdkdh763nnjhf", --jwt 私钥，用于加密

	-- mysql配置
	--ERROR 1045 (28000): Access denied for user 'root'@'192.168.1.25' (using password: YES)
	--原因是 非本机不可以root 登录
	mysql = {
		timeout = 5000,
		connect_config = {
			host = "192.168.1.14",
	        port = 3306,
	        database = "fishadmin",
	        user = "fish",
	        password = "111111",
	        max_packet_size = 1024 * 1024
		},
		pool_config = {
			max_idle_timeout = 20000, -- 20s
			pool_size = 50 -- connection pool size
		}
	},

	-- 上传文件配置，如上传的头像、文章中的图片等
	upload_config = {
		dir = "/opt/fishadmin/static", -- 文件目录，修改此值时须同时修改nginx配置文件中的$static_files_path值
	},

	cors_whitelist =  "http://192.168.1.35:9527", --请修改自己对应的 frontend url 
}