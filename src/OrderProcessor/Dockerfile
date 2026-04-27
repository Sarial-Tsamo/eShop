FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Install .NET 10.0 SDK
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=$PATH:/usr/share/dotnet

# Copy central package versions
COPY Directory.Packages.props ./

# Copy OrderProcessor project
COPY src/OrderProcessor/OrderProcessor.csproj ./src/OrderProcessor/

# Restore dependencies
RUN dotnet restore ./src/OrderProcessor/OrderProcessor.csproj

# Copy everything
COPY . .

# Publish OrderProcessor
RUN dotnet publish ./src/OrderProcessor/OrderProcessor.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/runtime:9.0
WORKDIR /app

# Install .NET 10.0 runtime
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --runtime dotnet --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=$PATH:/usr/share/dotnet

COPY --from=build /app/publish .

ENTRYPOINT [ "dotnet", "OrderProcessor.dll" ]

