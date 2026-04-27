###############
# Build stage
###############

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Install wget and .NET 10.0 SDK
RUN apt-get update && apt-get install -y wget && \
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Copy solution files and central package versions
COPY Directory.Packages.props .

# Copy all project files needed for restore
COPY src/WebApp/WebApp.csproj src/WebApp/
COPY src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj src/eShop.ServiceDefaults/
COPY src/Shared/ src/Shared/

# Restore dependencies
RUN dotnet restore src/WebApp/WebApp.csproj

# Copy everything
COPY . .

# Publish WebApp
RUN dotnet publish ./src/WebApp/WebApp.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

###############
# Runtime stage
###############

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Install .NET 10.0 runtime
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

ENTRYPOINT ["dotnet", "WebApp.dll"]
