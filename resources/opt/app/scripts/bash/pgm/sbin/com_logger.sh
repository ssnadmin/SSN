#!/bin/bash
##################################################
# プログラム名:  com_logger.sh
# 説明        :  汎用・共通ロガー。
# 引数        :  なし
# 戻り値      :  
# 作成者      :  t.nishizawa
# 修正履歴    :  2021/02/23(初回登録)
##################################################
##################################################
# 関数名      :  com_writelog
# 説明        :  汎用ログ出力
# 引数        :  ｰi : メッセージID
#             :  ｰm : マルチ出力モード
#             :  ｰc : メッセージカタログを指定する
# 戻り値      :    0:正常
#                  1:正常終了(スキップ)
#                255:異常終了
# 作成者      :  フルネーム
# 修正履歴    :  YYYY/MM/DD(初回登録)
##################################################
function com_writelog() {

  # オプション解析
  local OPT OPTIND OPTARG flg_i=false msg_id flg_m=false value_m
  while getopts "i:m" OPT; do
    case ${OPT} in
      i)  flg_i=true ; msg_id="${OPTARG}" ;;
      m)  flg_m=true ;;
      c)  flg_c=true ; message_catarog="${OPT_ARG}";;
      \?) com_writelog -i SSNSH0050E ${LINENO} "${OPT}" ; return ${EXIT_CODE_ABNORMAL} ;;
    esac
  done
  shift $((OPTIND - 1))

  # オプションチェック
  if ${flg_i}; then com_writelog -i SSNSH0051E ${LINENO} "-i" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if ${flg_m}; then com_writelog -i SSNSH0051E ${LINENO} "-m" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_i}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-f" "メッセージID" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ ! -e "${value_f}" ]; then com_writelog -i SSNSH0060E ${LINENO} "${value_f}" ; return ${EXIT_CODE_ABNORMAL} ; fi
  if [ -z "${value_v}" ]; then com_writelog -i SSNSH0054E ${LINENO} "-v" "取得する設定値" ; return ${EXIT_CODE_ABNORMAL} ; fi

  # カタログからメッセージ取得
  if ${flg_c}; then com_writelog -i SSNSH0092I ${LINENO} "メッセージカタログ[${message_catarog}]を使用します。"
  msg=$(com_get_conf_value -f ${message_catarog} -v ${msg_id}) ; lastexitcode=${?}
  if [ ${lastexitcode} -ne ${EXIT_CODE_NORMAL} ]; then return ${EXIT_CODE_ABNORMAL} ; fi

  # ファイルロック

  # ログファイルに出力
  


  return ${EXIT_CODE_NORMAL}

}

