#!/usr/bin/env bash

pdk_parse_args() {
    PDK=gpdk45
    TOOL_ARGS=()
    while (( $# )); do
        case "$1" in
            -p)
                if (( $# < 2 )) || [[ "$2" == -* ]]; then
                    printf 'Erro: -p exige sky130, gpdk45, free45 ou ics55.\n' >&2
                    return 2
                fi
                PDK="$2"
                shift 2
                ;;
            -h|--help)
                printf 'Uso: %s [-p sky130|gpdk45|free45|ics55] [-- opções da ferramenta]\n' "${0##*/}"
                printf 'Padrão: gpdk45.\n'
                exit 0
                ;;
            --)
                shift
                TOOL_ARGS=("$@")
                break
                ;;
            *)
                printf 'Erro: argumento desconhecido: %s\n' "$1" >&2
                return 2
                ;;
        esac
    done
    case "$PDK" in
        sky130|gpdk45|free45|ics55) ;;
        *) printf 'Erro: PDK inválido: %s\n' "$PDK" >&2; return 2 ;;
    esac
    export PDK
}
