FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Install wget and .NET 10.0 SDK
RUN apt-get update && apt-get install -y wget && \
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Webhooks.API project
COPY src/Webhooks.API/Webhooks.API.csproj ./src/Webhooks.API/

# Restore dependencies
RUN dotnet restore ./src/Webhooks.API/Webhooks.API.csproj

# Copy everything
COPY . .

# Publish Webhooks.API
RUN dotnet publish ./src/Webhooks.API/Webhooks.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Install wget and .NET 10.0 runtime
RUN apt-get update && apt-get install -y wget && \
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

RUN apt-get update && apt-get install -y libgssapi-krb5-2

ENTRYPOINT ["dotnet", "Webhooks.API.dll"]