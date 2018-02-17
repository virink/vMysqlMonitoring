# vMysqlMonitoring

## OSX 10.12 (swift)

### Version

**1.1 Beta**

**1.0 Beta**

### 功能

- 实时修改数据库连接配置，并缓存到数据目录
- 程序启动，自动清空 general_log 内容
- 点击标题实现排序
- 实时筛选SQL语句
- 双击行复制SQL语句到剪贴板

### Usage

- 首先确保成功连接数据库
- CMD+D setTimeNow 设置 时间断点
- 访问你的网站(执行语句) 
- CMD+R GetQuery 获取Sql语句
- CMD+F 快速设置filter筛选框焦点
- OpenLog 清空并开启Log日志
- 双击行复制SQL语句到剪贴板

### TODO

- [ ] 表格自动换行并自适应列表行高 (看心情吧emmmmmmmmmmmmm)

## Author

**Virink**

Blog : [https://www.virzz.com](https://www.virzz.com)

## ChangeLog

- 2018-02-17 重构程序，移除Pods，使用OC+libmysqlclient
    + 重写了下连接mysql的模块、通过OC调用系统libmysqlclient(😂😂😂😂😂)优化了下查询语句
- 2017-12-12 重构程序，使用Pods

## License

[LICENSE](LICENSE)

### [The MIT License (MIT) ](https://mit-license.org)

Copyright © 2017 <Virink>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Notice

I am so sorry about that I am not familiar with how layers of copyright notices interplay, if I did do something wrong, please tell me!