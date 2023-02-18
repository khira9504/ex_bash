# 出力 echo
echo "hoge"
echo "hogehoge"

# コメントアウト
# echo "hoge"
# echo "hogehoge"

# 変数の出力
number=1
string="hogehogehoge"
echo ${number}
echo ${string}

# 文字数の出力
echo ${#string}
# 文字抽出
echo ${string:0:5}

# 文字列の置換
echo ${string//h/ff}
echo ${string/h/ff}

# 配列の定義
array=("hoge1" "hoge2" "hoge3" "hoge4")
echo ${array[0]}

# 配列の全出力
echo ${array[@]}

# 指定範囲の出力
echo ${array[@]:1:2}

# ○番目以降の出力
echo ${array[@]:1}

# 配列の最後を出力
echo ${array[${#array[@]}-1]}

# ループ
for((i=0; i<${#array[@]}; ++i))
do
  echo ${array[$i]}
done

# 終了  
exit 0