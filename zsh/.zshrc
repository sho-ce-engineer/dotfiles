export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

eval "$(mise activate zsh)"
eval "$(starship init zsh)"

# STM32の開発環境がある場合のみパスを設定する
if [ -d "/Applications/STMicroelectronics" ]; then
    export STM32_PRG_PATH=/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/bin
    export STM32CubeMX_PATH=/Applications/STMicroelectronics/STM32CubeMX.app/Contents/Resources
fi