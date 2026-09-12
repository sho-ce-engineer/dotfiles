export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"

# STM32の開発環境がある場合のみパスを設定する
if [ -d "/Applications/STMicroelectronics" ]; then
    export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin
    export STM32CubeMX_PATH=/Applications/STMicroelectronics/STM32CubeMX.app/Contents/Resources
fi