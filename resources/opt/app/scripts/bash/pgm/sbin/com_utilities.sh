#!/bin/bash
##################################################
# プログラム名:  com_utilities.sh
# 説明        :  共通処理関数ファイル
# 引数        :  なし
# 戻り値      :  なし
# 作成者      :  フルネーム
# 修正履歴    :  YYYY/MM/DD(初回登録)
##################################################
## 初期設定
. ${SCRIPT_BASH}/pgm/conf/common.conf

##################################################
#関数名      :  com_get_conf_value
#説明        :  コンフィグ設定値取得
#引数        :  -f : コンフィグファイル
#            :  -v : 取得する設定値
#戻り値      :    0:正常
#                 1:正常(検索にマッチせず)
#               255:異常終了
#作成者      :  t.nishizawa
#修正履歴    :  2021/02/23(初回登録)
##################################################
function com_get_conf_value() {

  # オプション解析
  local OPT OPTIND OPTARG flg_f=false value_f flg_v=false value_v
  declare -a conf_value
  while getopts "f:v:" OPT; do
    case ${OPT} in
      f)  flg_f=true ; value_f="${OPTARG}" ;;
      v)  flg_v=true ; value_v="${OPTARG}" ;;
      \?) com_writelog -i SSNSH0050E ${LINENO} "${OPT}" ; return ${EXIT_CODE_ABNORMAL} ;;
    esac
  done
  shift $((OPTIND - 1))

  # オプションチェック
  if ${flg_f}; then com_writelog -i SSNSH0051E ${LINENO} "-f" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if ${flg_v}; then com_writelog -i SSNSH0051E ${LINENO} "-v" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_f}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-f" "読込先コンフィグファイル" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ ! -e "${value_f}" ]; then com_writelog -i SSNSH0060E ${LINENO} "${value_f}" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_v}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-v" "取得する設定値" ; return ${EXIT_CODE_ABNORMAL} ; fi

  # コンフィグファイル読込、設定値取得
  conf_value=($(cat ${value_f} | grep -w -e "^${value_v}" && cut -d= -f2- 2>&1)) ; lastexitcode=${?}
  # 戻り値1:パターンマッチせず  戻り値2以上:コマンドの異常
  if [ ${lastexitcode} -eq 1 ]; then com_writelog -i SSNSH0031I ${LINENO} ${value_f} ${value_v} ; return ${EXIT_CODE_BREAK}
  elif [ ${lastexitcode} -gt 2 ]; then com_writelog -i SSNSH0070E ${LINENO} "cat ${value_f} | grep -w -e "^${value_v}" && cut -d= -f2-" ${lastexitcode} ${conf_value} ; return ${EXIT_CODE_ABNORMAL}
  else com_writelog -i SSNSH0030I ${LINENO} ${value_f} "${conf_value}"

  echo "${conf_value[@]}"
  return ${EXIT_CODE_NORMAL}

}

