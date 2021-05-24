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

##################################################
#関数名      :  com_set_conf_value
#説明        :  コンフィグ設定値設定
#引数        :  -f : コンフィグファイル
#               -n : 設定先変数名
#               -v : 新設定値
#戻り値      :    0:正常
#                 1:正常(検索にマッチせず)
#               255:異常終了
#作成者      :  t.nishizawa
#修正履歴    :  2021/02/23(初回登録)
##################################################
function com_set_conf_value() {

  # オプション解析
  local OPT OPTIND OPTARG flg_f=false value_f flg_n=false value_n flg_v=false value_v before_value after_value conf_value
  while getopts "f:n:v:" OPT; do
    case ${OPT} in
      f)  flg_f=true ; value_f="${OPTARG}" ;;
      n)  flg_n=true ; value_n="${OPTARG}" ;;
      v)  flg_v=true ; value_v="${OPTARG}" ;;
      \?) com_writelog -i SSNSH0050E ${LINENO} "${OPT}" ; return ${EXIT_CODE_ABNORMAL} ;;
    esac
  done
  shift $((OPTIND - 1))

  # オプションチェック
  if ${flg_f}; then com_writelog -i SSNSH0051E ${LINENO} "-f" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if ${flg_n}; then com_writelog -i SSNSH0051E ${LINENO} "-n" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if ${flg_v}; then com_writelog -i SSNSH0051E ${LINENO} "-v" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_f}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-f" "書込先コンフィグファイル" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ ! -e "${value_f}" ]; then com_writelog -i SSNSH0060E ${LINENO} "${value_f}" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_n}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-n" "設定する変数名" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_v}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-v" "新設定値" ; return ${EXIT_CODE_ABNORMAL} ; fi

  # コンフィグファイル読込、設定値取得
  conf_value=($(cat ${value_f} | grep -w -e "^${value_v}" && cut -d= -f2- 2>&1)) ; lastexitcode=${?}
  # 戻り値1:パターンマッチせず  戻り値2以上:コマンドの異常
  if [ ${lastexitcode} -eq 1 ]; then com_writelog -i SSNSH0031I ${LINENO} ${value_f} ${value_v} ; return ${EXIT_CODE_BREAK} ; fi
  if [ ${lastexitcode} -gt 2 ]; then com_writelog -i SSNSH0070E ${LINENO} "cat ${value_f} | grep -w -e "^${value_v}" && cut -d= -f2-" ${lastexitcode} ${conf_value} ; return ${EXIT_CODE_ABNORMAL} ; fi
  before_conf_value=${conf_value}

  # 新設定値取込
  new_conf_value=$(cat ${value_f} | sed -e "s/^${value_n}=${before_value}/${value_n}=${value_v}/g" 2>&1) ; lastexitcode=${?}
  if [ ${lastexitcode} -ne 0 ]; then com_writelog -i SSNSH0034E ${LINENO} ${value_f} ${value_v} ; return ${EXIT_CODE_ABNORMAL} ; fi

  # 書込開始
  echo "${new_conf_value}" > ${value_f}
  com_writelog -i SSNSH0033I ${LINENO} ${value_f} ${value_v}

  return ${EXIT_CODE_NORMAL}


}
